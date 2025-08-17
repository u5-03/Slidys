//
//  SignLanguageWGesture.swift
//  HandGesturePackage
//
//  Created by Claude Code on 2025/08/02.
//

import Foundation
import HandGestureKit
import simd

/// アルファベットの「W」を表す手話ジェスチャー
/// 右手で人差し指・中指・薬指の3本を伸ばして立てる
public struct SignLanguageWGesture: SignLanguageProtocol {
    
    public init() {}
    
    // MARK: - Protocol Implementation
    
    public var gestureName: String { "手話 - W" }
    public var meaning: String { "W" }
    
    // MARK: - Gesture Requirements
    
    public func matches(_ gestureData: SingleHandGestureData) -> Bool {
        // 右手のみ対象
        guard gestureData.handKind == .right else { 
            return false 
        }
        
        // 人差し指・中指・薬指が伸びている
        let extendedFingers: [FingerType] = [.index, .middle, .ring]
        guard extendedFingers.allSatisfy({ gestureData.isFingerStraight($0) }) else { return false }
        
        // 親指と小指は曲がっている（しっかり曲がっていることを確認）
        guard gestureData
            .isFingerBentAtLeast(.thumb, minimumLevel: .slightlyBent) else {
            HandGestureLogger.logDebug("SignLanguageW: 親指が十分に曲がっていない")
            return false 
        }
        guard gestureData.isFingerBentAtLeast(.little, minimumLevel: .slightlyBent) else {
            HandGestureLogger.logDebug("SignLanguageW: 小指が十分に曲がっていない")
            return false 
        }
        
        // 手のひらは相手向き（forward）
        guard gestureData.isPalmFacing(.forward) else { return false }
        
        // 3本の指が上方向を向いている
        guard extendedFingers.allSatisfy({ gestureData.isFingerPointing($0, direction: .top) }) else { 
            HandGestureLogger.logDebug("SignLanguageW: 3本の指が上向きでない")
            return false 
        }
        
        // 3本の指の間に適度な間隔があることを確認（W字を形成）
        // 人差し指と中指が2cm以上離れている
        guard gestureData.handTrackingComponent.areTwoFingersSeparated(.index, .middle) else {
            HandGestureLogger.logDebug("SignLanguageW: 人差し指と中指の間隔が狭すぎる")
            return false
        }
        // 中指と薬指が2cm以上離れている
        guard gestureData.handTrackingComponent.areTwoFingersSeparated(.middle, .ring) else {
            HandGestureLogger.logDebug("SignLanguageW: 中指と薬指の間隔が狭すぎる")
            return false
        }
        
        return true
    }
}
