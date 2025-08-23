//
//  SignLanguageBGesture.swift
//  HandGesturePackage
//
//  Created by Yugo Sugiyama on 2025/07/30.
//

import Foundation
import HandGestureKit

/// アルファベットの「B」を表す手話ジェスチャー
/// 4本の指を揃えて伸ばし、親指は手のひらに軽く添える
public struct SignLanguageBGesture: SignLanguageProtocol {

    public init() {}

    // MARK: - Protocol Implementation

    public var gestureName: String { "手話 - B" }
    public var meaning: String { "B" }

    // MARK: - Gesture Requirements

    public func matches(_ gestureData: SingleHandGestureData) -> Bool {
        // 右手のみ対象
        guard gestureData.handKind == .right else {
            return false
        }

        // 4本の指が伸びている
        let extendedFingers: [FingerType] = [.index, .middle, .ring, .little]
        guard extendedFingers.allSatisfy({ gestureData.isFingerStraight($0) }) else {
            HandGestureLogger.logDebug("SignLanguageB: 4本の指が伸びていない")
            return false
        }

        // 親指は手のひらに添える(曲がっているが、完全に握っていない)
        guard
            gestureData
                .isFingerBentAtLeast(.thumb, minimumLevel: .moderatelyBent)
        else {
            HandGestureLogger.logDebug("SignLanguageB: 親指が曲がっていない")
            return false
        }

        // 手のひらは相手向き(forward)
        guard gestureData.isPalmFacing(.forward) else {
            HandGestureLogger.logDebug("SignLanguageB: 手のひらが前向きでない")
            return false
        }

        // 4本の指が揃っているかチェック(上向き)
        let allPointingUp = extendedFingers.allSatisfy({
            gestureData.isFingerPointing($0, direction: .top)
        })
        let allPointingForward = extendedFingers.allSatisfy({
            gestureData.isFingerPointing($0, direction: .forward)
        })

        guard allPointingUp || allPointingForward else {
            HandGestureLogger.logDebug("SignLanguageB: 指が揃っていない")
            return false
        }

        // 4本の指先がくっついているかチェック(隣接する指が4cm以内)
        // 閾値を緩和して、自然な指の配置を許容
        let touchThreshold: Float = 0.04  // 4cm

        // 人差し指と中指
        guard
            gestureData.handTrackingComponent.areFingerTipsTouching(
                .index, .middle, threshold: touchThreshold)
        else {
            HandGestureLogger.logDebug("SignLanguageB: 人差し指と中指が離れすぎている")
            return false
        }
        // 中指と薬指
        guard
            gestureData.handTrackingComponent.areFingerTipsTouching(
                .middle, .ring, threshold: touchThreshold)
        else {
            HandGestureLogger.logDebug("SignLanguageB: 中指と薬指が離れすぎている")
            return false
        }
        // 薬指と小指
        guard
            gestureData.handTrackingComponent.areFingerTipsTouching(
                .ring, .little, threshold: touchThreshold)
        else {
            HandGestureLogger.logDebug("SignLanguageB: 薬指と小指が離れすぎている")
            return false
        }

        return true
    }
}
