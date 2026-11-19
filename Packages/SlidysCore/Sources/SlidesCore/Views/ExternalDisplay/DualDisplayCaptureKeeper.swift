//
//  DualDisplayCaptureKeeper.swift
//  SlidesCore
//
//  iPhone Duo で内側・外側の両ディスプレイに同時に表示するための補助。
//  iPhone Duo は AVCaptureSession の実行中だけ両方のディスプレイを点けるため、
//  映像は使わないダミーのカメラセッション(前面カメラ・フレームは即破棄)を裏で動かし続ける。
//
//  外側ディスプレイに出す内容は iOS 27.1 の CameraCaptureAccessory(SwiftUI の sceneAccessory)で登録する
//  (SlideBaseView の CameraCaptureDeckAccessory)。登録が無いと外側には OS の「<アプリ名>でカメラを表示」が出るだけ。
//  外部ディスプレイ(HDMI / AirPlay)の Scene とは別物で、role は windowCameraCaptureAccessory になる。
//  実機でどの Scene / Screen が来たかは、Logger(subsystem: "Slidys", category: "DualDisplay")に出す。
//

#if os(iOS)
@preconcurrency import AVFoundation
import OSLog
import SwiftUI
import UIKit

private let dualDisplayLog = Logger(subsystem: "Slidys", category: "DualDisplay")

/// Camera failures remain visible without the former rotation investigation noise.
func dualDisplayError(_ message: String) {
    dualDisplayLog.error("[DuoCamera] \(message, privacy: .public)")
}

@MainActor
public final class DualDisplayCaptureKeeper: ObservableObject {
    public static let shared = DualDisplayCaptureKeeper()

    /// ダミーのカメラセッションを動かしているか
    @Published public private(set) var isRunning = false
    /// 権限なし・カメラなしなどで開始できなかったときの理由
    @Published public private(set) var lastError: String?
    /// 外側ディスプレイ(縦長)のスライドを横向きにするための回転方向。
    /// 端末の持ち方で上下が逆になるので、発表者メニューから反転できる
    @Published public var rotatesOuterClockwise = true
    @Published public var displayMode: DuoDisplayMode = .outerSlides {
        didSet { PresenterSlideCapture.shared.diagnostics("duo-mode old=\(oldValue.rawValue) new=\(displayMode.rawValue)") }
    }

    /// アプリが許可する画面の向き(SlidysAppDelegate が返す)。
    /// 2画面表示の開始・終了によって回転を制限しない。
    public let supportedInterfaceOrientations: UIInterfaceOrientationMask = .all

    private let session = AVCaptureSession()
    /// AVCaptureSession の startRunning / stopRunning はブロックするので専用キューで呼ぶ
    private let sessionQueue = DispatchQueue(label: "Slidys.DualDisplayCaptureKeeper")
    private let sampleBufferDelegate = DiscardingSampleBufferDelegate()
    private var isConfigured = false
    private var observers: [NSObjectProtocol] = []
    private var startTask: Task<Void, Never>?
    private var startRequestID = UUID()

    private init() {}

    public func toggle() {
        if isRunning { stop() } else { start() }
    }

    public func start(mode: DuoDisplayMode? = nil) {
        if let mode { displayMode = mode }
        guard !isRunning, startTask == nil else { return }
        lastError = nil
        let requestID = UUID()
        startRequestID = requestID
        startTask = Task {
            defer { if startRequestID == requestID { startTask = nil } }
            let granted = await requestCameraAccess()
            guard !Task.isCancelled else { return }
            guard granted else {
                lastError = "カメラへのアクセスが許可されていません"
                return
            }
            guard configureIfNeeded() else {
                dualDisplayError("configure failed: \(lastError ?? "-")")
                return
            }
            observeSessionAndScenes()
            let session = session
            sessionQueue.async {
                session.startRunning()
            }
            isRunning = true
        }
    }

    public func stop() {
        startTask?.cancel()
        startTask = nil
        startRequestID = UUID()
        guard isRunning else { return }
        let session = session
        sessionQueue.async {
            session.stopRunning()
        }
        isRunning = false
        observers.forEach(NotificationCenter.default.removeObserver)
        observers.removeAll()
    }

    private func requestCameraAccess() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .video)
        default:
            return false
        }
    }

    /// 前面カメラ入力 + フレームを捨てるだけの出力。解像度は最低限にして負荷を抑える
    private func configureIfNeeded() -> Bool {
        guard !isConfigured else { return true }
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
                ?? AVCaptureDevice.default(for: .video) else {
            lastError = "カメラが見つかりません"
            return false
        }
        do {
            let input = try AVCaptureDeviceInput(device: device)
            let output = AVCaptureVideoDataOutput()
            output.alwaysDiscardsLateVideoFrames = true
            output.setSampleBufferDelegate(sampleBufferDelegate, queue: sessionQueue)

            session.beginConfiguration()
            defer { session.commitConfiguration() }
            if session.canSetSessionPreset(.low) {
                session.sessionPreset = .low
            }
            guard session.canAddInput(input), session.canAddOutput(output) else {
                lastError = "カメラセッションを構成できません"
                return false
            }
            session.addInput(input)
            session.addOutput(output)
            isConfigured = true
            return true
        } catch {
            lastError = "カメラ入力を作成できません: \(error.localizedDescription)"
            return false
        }
    }

    /// 実機検証用: セッションの中断や Scene / Screen の接続をログに出す。
    /// 他アプリにカメラを取られたなどで中断したら isRunning に反映する
    private func observeSessionAndScenes() {
        guard observers.isEmpty else { return }
        let center = NotificationCenter.default
        observers.append(center.addObserver(forName: AVCaptureSession.wasInterruptedNotification, object: session, queue: .main) { notification in
            let reason = (notification.userInfo?[AVCaptureSessionInterruptionReasonKey] as? Int) ?? -1
            dualDisplayError("capture session interrupted reason=\(reason)")
        })
        observers.append(center.addObserver(forName: AVCaptureSession.runtimeErrorNotification, object: session, queue: .main) { notification in
            let error = notification.userInfo?[AVCaptureSessionErrorKey] as? Error
            dualDisplayError("capture session runtime error \(error?.localizedDescription ?? "-")")
        })
    }

}

/// 映像は使わないので、届いたフレームは何もせず捨てる
private final class DiscardingSampleBufferDelegate: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, @unchecked Sendable {}
#endif
