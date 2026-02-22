//
//  HeadMotionManager.swift
//  HeadPosturePackage
//
//  Created by Yugo Sugiyama on 2025/12/14.
//

import Foundation
import os
import CoreMotion
import Observation
import simd

/// オイラー角の構造体
struct EulerAngles {
    let pitch: Double
    let roll: Double
    let yaw: Double
}

@Observable
@MainActor
final class HeadMotionManager: NSObject {
    private nonisolated(unsafe) let motionManager = CMHeadphoneMotionManager()

    // 生のジャイロ値
    var rawPitch = 0.0
    var rawRoll = 0.0
    var rawYaw = 0.0

    var rawQuaternionX = 0.0
    var rawQuaternionY = 0.0
    var rawQuaternionZ = 0.0
    var rawQuaternionW = 1.0

    // リセット時の基準クォータニオン
    @ObservationIgnored
    private var referenceQuaternion = simd_quatd(ix: 0, iy: 0, iz: 0, r: 1)

    // リセット後の相対的なクォータニオン（UI表示用）
    var relativeQuaternionX = 0.0
    var relativeQuaternionY = 0.0
    var relativeQuaternionZ = 0.0
    var relativeQuaternionW = 1.0

    // 相対的なオイラー角
    var pitch = 0.0
    var roll = 0.0
    var yaw = 0.0

    /// モーションセンサー対応AirPodsが接続されているか
    /// CMHeadphoneMotionManagerDelegateで接続状態を監視
    var isAvailable = false
    var isActive = false
    var errorMessage: String?

    /// モーション権限が許可されているか
    var isMotionPermissionGranted = false

    // 閾値監視
    var isMonitoring = false
    var currentViolation: ThresholdViolation?
    var threshold = PostureThreshold()

    private var violationStartTime: Date?

    // 急激な動き検出用
    var suddenMovement: SuddenMovementType?
    private var previousQuaternion: simd_quatd?
    private var previousUpdateTime: Date?
    private let suddenMovementThreshold = 2.0  // rad/s - 急激な動きと判定する角速度
    private let suddenMovementCooldown: TimeInterval = 0.5  // 連続検出を防ぐクールダウン
    private var lastSuddenMovementTime: Date?

    override init() {
        super.init()
        // デリゲートを設定してAirPods接続状態を監視
        motionManager.delegate = self
        isAvailable = false
        checkMotionPermission()
    }

    /// モーション権限の状態を確認
    func checkMotionPermission() {
        isMotionPermissionGranted = CMHeadphoneMotionManager.authorizationStatus() == .authorized
    }

    /// モーション権限をリクエスト（async版）
    func requestMotionPermission() async {
        guard motionManager.isDeviceMotionAvailable else {
            isMotionPermissionGranted = false
            return
        }

        if CMHeadphoneMotionManager.authorizationStatus() == .authorized {
            isMotionPermissionGranted = true
            return
        }

        if CMHeadphoneMotionManager.authorizationStatus() == .notDetermined {
            await withCheckedContinuation { continuation in
                let hasResumed = OSAllocatedUnfairLock(initialState: false)

                motionManager.startDeviceMotionUpdates(to: .main) { [weak self] _, error in
                    Task { @MainActor in
                        guard hasResumed.withLock({
                            guard !$0 else { return false }
                            $0 = true
                            return true
                        }) else { return }

                        self?.isMotionPermissionGranted = (error == nil)
                        self?.motionManager.stopDeviceMotionUpdates()
                        continuation.resume()
                    }
                }

                Task { @MainActor [weak self] in
                    try? await Task.sleep(for: .seconds(3))
                    guard hasResumed.withLock({
                        guard !$0 else { return false }
                        $0 = true
                        return true
                    }) else { return }

                    self?.motionManager.stopDeviceMotionUpdates()
                    self?.checkMotionPermission()
                    continuation.resume()
                }
            }
        } else {
            isMotionPermissionGranted = false
        }
    }

    /// 初期接続状態を確認（アプリ起動時に呼び出す）
    func checkInitialConnection() {
        guard motionManager.isDeviceMotionAvailable else { return }

        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            Task { @MainActor in
                guard let self = self else { return }
                if motion != nil {
                    self.isAvailable = true
                }
            }
        }

        Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(0.5))
            guard let self = self else { return }
            if !self.isActive {
                self.motionManager.stopDeviceMotionUpdates()
            }
        }
    }

    /// 現在の位置を基準位置としてリセット
    func resetReference() {
        referenceQuaternion = simd_quatd(
            ix: rawQuaternionX,
            iy: rawQuaternionY,
            iz: rawQuaternionZ,
            r: rawQuaternionW
        )
        updateRelativeValues()
    }

    private func updateRelativeValues() {
        let currentQuat = simd_quatd(
            ix: rawQuaternionX,
            iy: rawQuaternionY,
            iz: rawQuaternionZ,
            r: rawQuaternionW
        )

        let relativeQuat = simd_mul(simd_inverse(referenceQuaternion), currentQuat)

        relativeQuaternionX = relativeQuat.imag.x
        relativeQuaternionY = relativeQuat.imag.y
        relativeQuaternionZ = relativeQuat.imag.z
        relativeQuaternionW = relativeQuat.real

        let angles = quaternionToEuler(relativeQuat)
        pitch = angles.pitch
        roll = angles.roll
        yaw = -angles.yaw
    }

    private func quaternionToEuler(_ quat: simd_quatd) -> EulerAngles {
        let quatX = quat.imag.x
        let quatY = quat.imag.y
        let quatZ = quat.imag.z
        let quatW = quat.real

        // Roll (x-axis rotation)
        let sinrCosp = 2 * (quatW * quatX + quatY * quatZ)
        let cosrCosp = 1 - 2 * (quatX * quatX + quatY * quatY)
        let roll = atan2(sinrCosp, cosrCosp)

        // Pitch (y-axis rotation)
        let sinp = 2 * (quatW * quatY - quatZ * quatX)
        let pitch: Double
        if abs(sinp) >= 1 {
            pitch = copysign(.pi / 2, sinp)
        } else {
            pitch = asin(sinp)
        }

        // Yaw (z-axis rotation)
        let sinyCosp = 2 * (quatW * quatZ + quatX * quatY)
        let cosyCosp = 1 - 2 * (quatY * quatY + quatZ * quatZ)
        let yaw = atan2(sinyCosp, cosyCosp)

        return EulerAngles(pitch: pitch, roll: roll, yaw: yaw)
    }

    func startTracking() {
        guard motionManager.isDeviceMotionAvailable else {
            errorMessage = "Headphone motion is not available on this device"
            return
        }

        guard !isActive else { return }

        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            Task { @MainActor in
                guard let self = self else { return }

                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }

                guard let motion = motion else { return }

                if !self.isAvailable {
                    self.isAvailable = true
                }

                self.rawPitch = motion.attitude.pitch
                self.rawRoll = motion.attitude.roll
                self.rawYaw = motion.attitude.yaw

                self.rawQuaternionX = motion.attitude.quaternion.x
                self.rawQuaternionY = motion.attitude.quaternion.y
                self.rawQuaternionZ = motion.attitude.quaternion.z
                self.rawQuaternionW = motion.attitude.quaternion.w

                self.updateRelativeValues()
                self.detectSuddenMovement()
                self.updateMonitoring()
            }
        }

        isActive = true
        errorMessage = nil
    }

    func stopTracking() {
        motionManager.stopDeviceMotionUpdates()
        isActive = false
        stopMonitoring()
    }

    // MARK: - 閾値監視

    /// 閾値を更新
    func updateThreshold(_ newThreshold: PostureThreshold) {
        threshold = newThreshold
    }

    /// 監視を開始
    func startMonitoring() {
        isMonitoring = true
        violationStartTime = nil
        currentViolation = nil
    }

    /// 監視を停止
    func stopMonitoring() {
        isMonitoring = false
        violationStartTime = nil
        currentViolation = nil
    }

    /// 現在の姿勢が閾値を超えているかチェック
    private func checkThresholdViolation() -> ThresholdViolation? {
        let rollDegrees = Int(roll * 180 / .pi)
        if roll < threshold.rollMin {
            return .rollTooForward(
                currentDegrees: rollDegrees,
                thresholdDegrees: Int(threshold.rollMin * 180 / .pi)
            )
        } else if roll > threshold.rollMax {
            return .rollTooBackward(
                currentDegrees: rollDegrees,
                thresholdDegrees: Int(threshold.rollMax * 180 / .pi)
            )
        }

        let yawDegrees = Int(yaw * 180 / .pi)
        if yaw < threshold.yawMin {
            return .yawTooLeft(
                currentDegrees: yawDegrees,
                thresholdDegrees: Int(threshold.yawMin * 180 / .pi)
            )
        } else if yaw > threshold.yawMax {
            return .yawTooRight(
                currentDegrees: yawDegrees,
                thresholdDegrees: Int(threshold.yawMax * 180 / .pi)
            )
        }

        let pitchDegrees = Int(pitch * 180 / .pi)
        if pitch < threshold.pitchMin {
            return .tiltTooLeft(
                currentDegrees: pitchDegrees,
                thresholdDegrees: Int(threshold.pitchMin * 180 / .pi)
            )
        } else if pitch > threshold.pitchMax {
            return .tiltTooRight(
                currentDegrees: pitchDegrees,
                thresholdDegrees: Int(threshold.pitchMax * 180 / .pi)
            )
        }

        return nil
    }

    /// 閾値監視の更新
    private func updateMonitoring() {
        guard isMonitoring else { return }

        let violation = checkThresholdViolation()
        currentViolation = violation

        if violation != nil {
            if violationStartTime == nil {
                violationStartTime = Date()
            }
        } else {
            violationStartTime = nil
        }
    }

    // MARK: - 急激な動き検出

    /// 急激な動きを検出
    private func detectSuddenMovement() {
        let now = Date()
        let currentQuat = simd_quatd(
            ix: rawQuaternionX,
            iy: rawQuaternionY,
            iz: rawQuaternionZ,
            r: rawQuaternionW
        )

        defer {
            previousQuaternion = currentQuat
            previousUpdateTime = now
        }

        // クールダウン中はスキップ
        if let lastTime = lastSuddenMovementTime,
           now.timeIntervalSince(lastTime) < suddenMovementCooldown {
            return
        }

        guard let prevQuat = previousQuaternion,
              let prevTime = previousUpdateTime else {
            return
        }

        let deltaTime = now.timeIntervalSince(prevTime)
        guard deltaTime > 0.001 else { return }

        let deltaQuat = simd_mul(simd_inverse(prevQuat), currentQuat)
        let angle = 2 * acos(min(1.0, abs(deltaQuat.real)))
        let angularVelocity = angle / deltaTime

        if angularVelocity > suddenMovementThreshold {
            lastSuddenMovementTime = now

            let movement = classifySuddenMovement(deltaQuat: deltaQuat, angularVelocity: angularVelocity)
            suddenMovement = movement

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.suddenMovement = nil
            }
        }
    }

    /// 急激な動きの種類を分類
    private func classifySuddenMovement(deltaQuat: simd_quatd, angularVelocity: Double) -> SuddenMovementType {
        let deltaX = deltaQuat.imag.x
        let deltaY = deltaQuat.imag.y
        let deltaZ = deltaQuat.imag.z

        let absX = abs(deltaX)
        let absY = abs(deltaY)
        let absZ = abs(deltaZ)

        if absX > absY && absX > absZ {
            return deltaX > 0 ? .nodDown : .nodUp
        } else if absY > absX && absY > absZ {
            return deltaY > 0 ? .turnRight : .turnLeft
        } else {
            return deltaZ > 0 ? .tiltRight : .tiltLeft
        }
    }

    nonisolated deinit {
        motionManager.stopDeviceMotionUpdates()
    }
}

// MARK: - CMHeadphoneMotionManagerDelegate

extension HeadMotionManager: CMHeadphoneMotionManagerDelegate {
    nonisolated func headphoneMotionManagerDidConnect(_ manager: CMHeadphoneMotionManager) {
        Task { @MainActor in
            self.isAvailable = true
        }
    }

    nonisolated func headphoneMotionManagerDidDisconnect(_ manager: CMHeadphoneMotionManager) {
        Task { @MainActor in
            self.isAvailable = false
            if self.isMonitoring {
                self.stopMonitoring()
            }
        }
    }
}

// MARK: - 急激な動きの種類

enum SuddenMovementType: CaseIterable {
    case nodUp
    case nodDown
    case turnLeft
    case turnRight
    case tiltLeft
    case tiltRight

    var localizedName: String {
        switch self {
        case .nodUp:
            return "上を向く"
        case .nodDown:
            return "下を向く"
        case .turnLeft:
            return "左を向く"
        case .turnRight:
            return "右を向く"
        case .tiltLeft:
            return "左に傾ける"
        case .tiltRight:
            return "右に傾ける"
        }
    }

    var icon: String {
        switch self {
        case .nodUp: return "arrow.up"
        case .nodDown: return "arrow.down"
        case .turnLeft: return "arrow.left"
        case .turnRight: return "arrow.right"
        case .tiltLeft: return "arrow.counterclockwise"
        case .tiltRight: return "arrow.clockwise"
        }
    }
}
