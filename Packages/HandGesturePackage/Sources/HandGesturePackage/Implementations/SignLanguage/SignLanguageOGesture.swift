//
//  SignLanguageOGesture.swift
//  HandGesturePackage
//
//  Created by Yugo Sugiyama on 2025/07/30.
//

import Foundation
import HandGestureKit

/// アルファベットの「O」を表す手話ジェスチャー
/// 右手で親指と人差し指を丸く合わせ、他の指は軽く曲げる
public struct SignLanguageOGesture: SignLanguageProtocol {
    
    public init() {}
    
    // MARK: - Protocol Implementation
    
    public var gestureName: String { "手話 - O" }
    public var meaning: String { "O" }
    
    // MARK: - Gesture Requirements
    
    public func matches(_ gestureData: SingleHandGestureData) -> Bool {
        // 右手のみ対象
        guard gestureData.handKind == .right else { 
            // 左手の場合は静かに失敗（これは正常な動作）
            return false 
        }
        
        // 親指と人差し指は曲がっている必要がある
        guard gestureData.isFingerBent(.thumb) else { return false }
        guard gestureData.isFingerBent(.index) else { return false }
        
        // 中指、薬指、小指は「かなり曲がっている」以上の状態である必要がある
        // これによりOKジェスチャーのような軽く曲げただけの状態を除外
        let otherFingers: [FingerType] = [.middle, .ring, .little]
        guard otherFingers
            .allSatisfy({ gestureData.isFingerBentAtLeast($0, minimumLevel: .slightlyBent) }) else {
            return false
        }

        // 手話Oでは手のひらは左を向く
        guard gestureData.isPalmFacing(.left) else { return false }
        
        // 親指と人差し指が接触している（O字を形成）
        guard gestureData.handTrackingComponent.isThumbTouchingFinger(.index, threshold: 0.03) else { return false }
        
        return true
    }
}
