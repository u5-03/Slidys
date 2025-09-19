//
//  SignLanguageIGesture.swift
//  HandGesturePackage
//
//  Created by Claude Code on 2025/08/02.
//

import Foundation
import HandGestureKit

/// アルファベットの「I」を表す手話ジェスチャー
/// 右手で握りこぶしを作り、小指だけを真っ直ぐ上に伸ばす
public struct SignLanguageIGesture: SignLanguageProtocol {

    public init() {}

    // MARK: - Protocol Implementation

    public var gestureName: String { "手話 - I" }
    public var meaning: String { "I" }

    // MARK: - Gesture Requirements

    public func matches(_ gestureData: SingleHandGestureData) -> Bool {
        // 右手のみ対象
        guard gestureData.handKind == .right else {
            return false
        }

        // 小指が伸びている
        guard gestureData.isFingerStraight(.little) else { return false }

        // 他の指は曲がっている
        let bentFingers: [FingerType] = [.thumb, .index, .middle, .ring]
        guard bentFingers.allSatisfy({ gestureData.isFingerBent($0) }) else { return false }

        // 手のひらは相手向き(forward)
        guard gestureData.isPalmFacing(.forward) else { return false }

        // 小指が上を向いている
        guard gestureData.isFingerPointing(.little, direction: .top) else { return false }

        return true
    }
}
