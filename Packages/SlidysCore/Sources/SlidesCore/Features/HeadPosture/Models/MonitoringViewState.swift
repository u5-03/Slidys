//
//  MonitoringViewState.swift
//  HeadPosturePackage
//
//  State models for MonitoringView.
//

import Foundation

// MARK: - Monitoring View State

/// MonitoringViewの表示状態
struct MonitoringViewState: Sendable {
    let isMonitoring: Bool
    let isAvailable: Bool
    let currentViolation: ThresholdViolation?
    let pitch: Double
    let yaw: Double
    let roll: Double

    init(
        isMonitoring: Bool = false,
        isAvailable: Bool = true,
        currentViolation: ThresholdViolation? = nil,
        pitch: Double = 0,
        yaw: Double = 0,
        roll: Double = 0
    ) {
        self.isMonitoring = isMonitoring
        self.isAvailable = isAvailable
        self.currentViolation = currentViolation
        self.pitch = pitch
        self.yaw = yaw
        self.roll = roll
    }

    // MARK: - Preset States

    /// アイドル状態（監視停止中、AirPods接続済み）
    static let idle = MonitoringViewState(
        isMonitoring: false,
        isAvailable: true
    )

    /// 監視中
    static let monitoring = MonitoringViewState(
        isMonitoring: true,
        isAvailable: true
    )

    /// AirPods未接続
    static let disconnected = MonitoringViewState(
        isMonitoring: false,
        isAvailable: false
    )
}
