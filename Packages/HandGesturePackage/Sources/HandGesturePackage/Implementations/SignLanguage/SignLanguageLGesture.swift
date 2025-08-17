//
//  SignLanguageLGesture.swift
//  HandGesturePackage
//
//  Created by Claude Code on 2025/08/02.
//

import Foundation
import HandGestureKit

/// アルファベットの「L」を表す手話ジェスチャー
/// 右手で親指と人差し指を直角に伸ばす（L字型）
public struct SignLanguageLGesture: SignLanguageProtocol {
    
    public init() {}
    
    // MARK: - Protocol Implementation
    
    public var gestureName: String { "手話 - L" }
    public var meaning: String { "L" }
    
    // MARK: - Gesture Requirements
    
    public func matches(_ gestureData: SingleHandGestureData) -> Bool {
        // 右手のみ対象
        guard gestureData.handKind == .right else { 
            return false 
        }
        
        // 親指と人差し指が伸びている
        guard gestureData.isFingerStraight(.thumb) else { return false }
        guard gestureData.isFingerStraight(.index) else { return false }
        
        // 中指・薬指・小指は中程度以上曲がっている
        let bentFingers: [FingerType] = [.middle, .ring, .little]
        guard bentFingers.allSatisfy({ gestureData.isFingerBentAtLeast($0, minimumLevel: .moderatelyBent) }) else { 
            HandGestureLogger.logDebug("SignLanguageL: 中指・薬指・小指が十分に曲がっていない")
            return false 
        }
        
        // 手のひらは相手向き（forward）
        guard gestureData.isPalmFacing(.forward) else { return false }
        
        // L字形状の判定
        // 人差し指が上を向いている（許容角度を60度に緩和）
        guard gestureData.isFingerPointing(.index, direction: .top, tolerance: .pi / 3) else { 
            HandGestureLogger.logDebug("SignLanguageL: 人差し指が上向きでない")
            return false 
        }
        
        // 親指が左を向いている（L字を形成、許容角度を60度に緩和）
        guard gestureData.isFingerPointing(.thumb, direction: .left, tolerance: .pi / 3) else { 
            HandGestureLogger.logDebug("SignLanguageL: 親指が左向きでない")
            return false 
        }
        
        return true
    }
}