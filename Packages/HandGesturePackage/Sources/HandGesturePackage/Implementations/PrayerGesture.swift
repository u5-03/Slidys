//
//  PrayerGesture.swift
//  HandGesturePackage
//
//  Created by Claude on 2025/07/26.
//

import Foundation
import HandGestureKit

/// 祈りのジェスチャー(両手を合わせるジェスチャー)
public struct PrayerGesture: TwoHandsGestureProtocol {
    public var gestureName: String { "Prayer" }
    public var description: String { "両手を合わせた祈りのジェスチャー" }
    public var priority: Int { 10 }  // 優先度を高く設定

    // 判定用の閾値
    private let palmDistanceThreshold: Float = 0.05  // 5cm以内(手のひらがほぼ接触している状態)
    private let wristDistanceThreshold: Float = 0.15  // 15cm以内(手首はもっと離れている)
    private let fingerDistanceThreshold: Float = 0.10  // 10cm以内
    private let verticalOffsetThreshold: Float = 0.08  // 8cm以内の上下ズレ(少し緩める)

    public init() {}

    public func matches(_ gestureData: HandsGestureData) -> Bool {
        HandGestureLogger.logDebug("🙏 祈りジェスチャー判定開始")

        // データの有効性チェック
        let palmDistance = gestureData.palmCenterDistance
        if palmDistance > 1.0 || palmDistance.isInfinite {
            HandGestureLogger.logDebug("🙏 祈り判定失敗: 手のデータが無効です(距離: \(palmDistance * 100)cm)")
            return false
        }

        // デバッグ: 手のひらの向きを確認
        HandGestureLogger.logDebug("  - 左手の向き: \(gestureData.leftHand.palmDirection)")
        HandGestureLogger.logDebug("  - 右手の向き: \(gestureData.rightHand.palmDirection)")

        // 1. すべての指が伸びているか確認
        // 祈りのポーズでは指が完全に真っ直ぐでなくても良いため、カスタム判定を使用
        let fingers: [FingerType] = [.thumb, .index, .middle, .ring, .little]
        var allFingersStraight = true

        HandGestureLogger.logDebug("  - 指の状態:")
        for finger in fingers {
            // 祈りのポーズ用に緩い判定を使用(70度まで許容)
            let leftStraight = gestureData.leftHand.handTrackingComponent.isFingerStraight(
                finger, tolerance: .pi * 70 / 180)
            let rightStraight = gestureData.rightHand.handTrackingComponent.isFingerStraight(
                finger, tolerance: .pi * 70 / 180)

            HandGestureLogger.logDebug(
                "    - \(finger): 左=\(leftStraight ? "伸びている" : "曲がっている"), 右=\(rightStraight ? "伸びている" : "曲がっている")"
            )

            if !leftStraight || !rightStraight {
                allFingersStraight = false
            }
        }

        if !allFingersStraight {
            HandGestureLogger.logDebug("🙏 祈り判定失敗: 指が曲がっている")
            return false
        }

        // 2. 手のひらの向きを確認
        let leftPalmDirection = gestureData.leftHand.palmDirection
        let rightPalmDirection = gestureData.rightHand.palmDirection

        HandGestureLogger.logDebug("  - 手のひらの向き判定:")
        HandGestureLogger.logDebug("    - 左手: \(leftPalmDirection)")
        HandGestureLogger.logDebug("    - 右手: \(rightPalmDirection)")
        HandGestureLogger.logDebug("    - 向かい合っている(厳密): \(gestureData.arePalmsFacingEachOther)")

        // 祈りのポーズでは左手の手のひらが右を向き、右手の手のひらが左を向いている必要がある
        // より柔軟な判定のため、45度の許容角度を設定
        let leftPalmFacingRight = gestureData.leftHand.handTrackingComponent.isPalmFacingDirection(
            .right, tolerance: .pi / 4)
        let rightPalmFacingLeft = gestureData.rightHand.handTrackingComponent.isPalmFacingDirection(
            .left, tolerance: .pi / 4)

        HandGestureLogger.logDebug("    - 左手が右向き(45度許容): \(leftPalmFacingRight)")
        HandGestureLogger.logDebug("    - 右手が左向き(45度許容): \(rightPalmFacingLeft)")

        guard leftPalmFacingRight && rightPalmFacingLeft else {
            HandGestureLogger.logDebug("🙏 祈り判定失敗: 手のひらが向かい合っていない")
            return false
        }

        // 3. 手のひらの中心が近いか確認
        HandGestureLogger.logDebug(
            "  - 手のひら中心間距離: \(palmDistance * 100)cm (閾値: \(palmDistanceThreshold * 100)cm)")
        guard palmDistance < palmDistanceThreshold else {
            HandGestureLogger.logDebug("🙏 祈り判定失敗: 手のひらが離れすぎ - 距離: \(palmDistance * 100)cm")
            return false
        }

        // 4. 垂直方向のズレが許容範囲内か確認
        let verticalOffset = gestureData.verticalOffset
        HandGestureLogger.logDebug(
            "  - 垂直方向のズレ: \(verticalOffset * 100)cm (閾値: \(verticalOffsetThreshold * 100)cm)")
        guard verticalOffset < verticalOffsetThreshold else {
            HandGestureLogger.logDebug("🙏 祈り判定失敗: 上下のズレが大きい - ズレ: \(verticalOffset * 100)cm")
            return false
        }

        // 5. 手首の位置も近いか確認(補助的な判定)
        let wristDistance = gestureData.jointDistance(joint: .wrist)
        HandGestureLogger.logDebug(
            "  - 手首間距離: \(wristDistance * 100)cm (閾値: \(wristDistanceThreshold * 100)cm)")
        guard wristDistance < wristDistanceThreshold else {
            HandGestureLogger.logDebug("🙏 祈り判定失敗: 手首が離れすぎ - 距離: \(wristDistance * 100)cm")
            return false
        }

        HandGestureLogger.logGesture("🙏 祈りジェスチャー検出成功！")
        return true
    }
}
