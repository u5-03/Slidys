//
//  PostureThreshold.swift
//  HeadPosturePackage
//
//  Created by Yugo Sugiyama on 2025/12/14.
//

import Foundation

/// 姿勢の閾値設定
struct PostureThreshold: Codable, Equatable, Sendable {
    /// X軸（前後の傾き）の閾値（ラジアン）
    var pitchMin: Double
    var pitchMax: Double

    /// Y軸（左右を向く）の閾値（ラジアン）
    var yawMin: Double
    var yawMax: Double

    /// Z軸（左右の傾き）の閾値（ラジアン）
    var rollMin: Double
    var rollMax: Double

    /// 閾値を超えてから警告するまでの時間（秒）
    var warningDelay: Double

    init(
        pitchMin: Double = -.pi / 6,  // -30度
        pitchMax: Double = .pi / 6,   // +30度
        yawMin: Double = -.pi / 4,    // -45度
        yawMax: Double = .pi / 4,     // +45度
        rollMin: Double = -.pi / 6,   // -30度
        rollMax: Double = .pi / 6,    // +30度
        warningDelay: Double = 3.0
    ) {
        self.pitchMin = pitchMin
        self.pitchMax = pitchMax
        self.yawMin = yawMin
        self.yawMax = yawMax
        self.rollMin = rollMin
        self.rollMax = rollMax
        self.warningDelay = warningDelay
    }

    /// 度数法での値を取得
    var pitchMinDegrees: Double { pitchMin * 180 / .pi }
    var pitchMaxDegrees: Double { pitchMax * 180 / .pi }
    var yawMinDegrees: Double { yawMin * 180 / .pi }
    var yawMaxDegrees: Double { yawMax * 180 / .pi }
    var rollMinDegrees: Double { rollMin * 180 / .pi }
    var rollMaxDegrees: Double { rollMax * 180 / .pi }

    /// デフォルト値
    static let `default` = PostureThreshold()
}

/// 閾値超過の種類
enum ThresholdViolation: Equatable, Sendable {
    case rollTooForward(currentDegrees: Int, thresholdDegrees: Int)   // 頭が前に傾きすぎ（うなずき）
    case rollTooBackward(currentDegrees: Int, thresholdDegrees: Int)  // 頭が後ろに傾きすぎ
    case yawTooLeft(currentDegrees: Int, thresholdDegrees: Int)       // 左を向きすぎ
    case yawTooRight(currentDegrees: Int, thresholdDegrees: Int)      // 右を向きすぎ
    case tiltTooLeft(currentDegrees: Int, thresholdDegrees: Int)      // 左に傾きすぎ（首かしげ）
    case tiltTooRight(currentDegrees: Int, thresholdDegrees: Int)     // 右に傾きすぎ（首かしげ）

    var message: String {
        shortMessage
    }

    var shortMessage: String {
        switch self {
        case .rollTooForward:
            return "前に傾きすぎ"
        case .rollTooBackward:
            return "後ろに傾きすぎ"
        case .yawTooLeft:
            return "左を向きすぎ"
        case .yawTooRight:
            return "右を向きすぎ"
        case .tiltTooLeft:
            return "左に傾きすぎ"
        case .tiltTooRight:
            return "右に傾きすぎ"
        }
    }
}
