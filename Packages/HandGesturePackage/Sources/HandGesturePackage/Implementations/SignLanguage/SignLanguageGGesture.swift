//
//  SignLanguageGGesture.swift
//  HandGesturePackage
//
//  Created by Claude Code on 2025/08/02.
//

import Foundation
import HandGestureKit

/// アルファベットの「G」を表す手話ジェスチャー
/// 右手で人差し指を水平に伸ばし、親指は人差し指に平行に少し出す
public struct SignLanguageGGesture: SignLanguageProtocol {
    
    public init() {}
    
    // MARK: - Protocol Implementation
    
    public var gestureName: String { "手話 - G" }
    public var meaning: String { "G" }
    
    // MARK: - Gesture Requirements
    
    public func matches(_ gestureData: SingleHandGestureData) -> Bool {
        // 右手のみ対象
        guard gestureData.handKind == .right else { 
            return false 
        }
        
        // 人差し指が伸びている
        guard gestureData.isFingerStraight(.index) else { return false }

        // 中指・薬指・小指は曲がっている
        let bentFingers: [FingerType] = [.middle, .ring, .little]
        guard bentFingers
            .allSatisfy({ gestureData.isFingerBentAtLeast($0, minimumLevel: .slightlyBent) }) else { 
            HandGestureLogger.logDebug("SignLanguageG: 中指・薬指・小指が曲がっていない")
            return false 
        }
        
        // 手のひらは自分向き（backward）
        guard gestureData.isPalmFacing(.backward) else { 
            HandGestureLogger.logDebug("SignLanguageG: 手のひらが自分向きでない")
            return false 
        }
        
        // 人差し指が左を向いている
        guard gestureData.isFingerPointing(.index, direction: .left) else { 
            HandGestureLogger.logDebug("SignLanguageG: 人差し指が左向きでない")
            return false 
        }
        return true
    }
}
