//
//  SignLanguageArigatouGesture.swift
//  HandGesturePackage
//
//  Created by Yugo Sugiyama on 2025/08/07.
//

import Foundation
import HandGestureKit

// MARK: - 第一段階のジェスチャー(独立して検出可能)

/// ありがとうの初期位置
/// - 左手: 全指伸展、手のひら下向き、指先右向き
/// - 右手: 全指伸展、手のひら左向き、指先前向き、左手の近くに配置
public struct ArigatouInitialPositionGesture: TwoHandGestureProtocol {

    public init() {}

    public var gestureName: String { "ありがとう初期位置" }
    public var priority: Int { 50 }
    public var category: GestureCategory { .custom }
    public var gestureType: GestureType { .twoHand }

    public func matches(_ gestureData: HandsGestureData) -> Bool {
        // 両手のすべての指が伸びている
        guard gestureData.leftHand.areAllFingersExtended(),
            gestureData.rightHand.areAllFingersExtended()
        else {
            return false
        }

        // 左手: 手のひらが下向き
        guard gestureData.leftHand.isPalmFacing(.bottom) else {
            return false
        }

        // 右手: 手のひらが左向き
        guard gestureData.rightHand.isPalmFacing(.left) else {
            return false
        }

        // 両手がほぼ同じ高さにある(垂直方向の差: 10cm以内)
        let verticalSeparation = abs(gestureData.handVerticalSeparation())
        guard verticalSeparation < 0.10 else {
            HandGestureLogger.logDebug(
                "❌ ArigatouInitial: 垂直差が大きすぎる: \(verticalSeparation)m (必要: < 0.10m)")
            return false
        }

        // 手首間の距離を取得(ログ用)
        let wristDistance = gestureData.jointToJointDistance(
            joint1: .wrist,
            hand1: .left,
            joint2: .wrist,
            hand2: .right
        )

        HandGestureLogger.logDebug(
            "✅ ArigatouInitial: 検出成功 (手首間: \(wristDistance)m, 垂直差: \(verticalSeparation)m)")
        return true
    }
}

// MARK: - 第二段階のジェスチャー(独立して検出可能)

/// ありがとうの最終位置
/// - 初期位置と同じ手の形
/// - 右手が上に移動している
public struct ArigatouFinalPositionGesture: TwoHandGestureProtocol {

    public init() {}

    public var gestureName: String { "ありがとう最終位置" }
    public var priority: Int { 50 }
    public var category: GestureCategory { .custom }
    public var gestureType: GestureType { .twoHand }

    public func matches(_ gestureData: HandsGestureData) -> Bool {
        // 両手のすべての指が伸びている
        guard gestureData.leftHand.areAllFingersExtended(),
            gestureData.rightHand.areAllFingersExtended()
        else {
            HandGestureLogger.logDebug("❌ ArigatouFinal: 指が伸びていない")
            return false
        }

        // 左手: 手のひらが下向き
        guard gestureData.leftHand.isPalmFacing(.bottom) else {
            HandGestureLogger.logDebug("❌ ArigatouFinal: 左手が下向きでない")
            return false
        }

        // 右手: 手のひらが左向き
        guard gestureData.rightHand.isPalmFacing(.left) else {
            HandGestureLogger.logDebug("❌ ArigatouFinal: 右手が左向きでない")
            return false
        }

        // 右手が左手より上にある(10cm以上)
        let verticalSeparation = gestureData.handVerticalSeparation()
        guard verticalSeparation >= 0.10 else {
            HandGestureLogger.logDebug(
                "❌ ArigatouFinal: 右手が上にない: \(verticalSeparation)m (必要: >= 0.10m)")
            return false
        }

        // 手首間の距離を取得(ログ用)
        let wristDistance = gestureData.jointToJointDistance(
            joint1: .wrist,
            hand1: .left,
            joint2: .wrist,
            hand2: .right
        )

        HandGestureLogger.logDebug(
            "✅ ArigatouFinal: 検出成功 (垂直: \(verticalSeparation)m, 手首間: \(wristDistance)m)")
        return true
    }
}

// MARK: - シリアルジェスチャー

/// 日本語の「ありがとう」を表すシリアル手話ジェスチャー
/// 初期位置から右手を上に移動させる動作で表現
public struct SignLanguageArigatouGesture: SerialGestureProtocol {

    public init() {}

    // MARK: - Protocol Implementation

    public var gestureName: String { "手話 - ありがとう" }
    public var meaning: String { "ありがとう" }
    public var intervalSeconds: TimeInterval { 3.0 }  // 3秒以内に次のジェスチャーを検出

    public var gestures: [BaseGestureProtocol] {
        return [
            ArigatouInitialPositionGesture(),
            ArigatouFinalPositionGesture(),
        ]
    }

    public var stepDescriptions: [String] {
        return [
            "両手を同じ高さに配置",
            "右手を上に移動",
        ]
    }
}
