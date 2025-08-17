//
//  PeaceSignGesture.swift
//  HandGesturePackage
//
//  Created by Yugo Sugiyama on 2025/07/16.
//

import HandGestureKit

/// ピースサインジェスチャー検出器
/// 人差し指と中指だけが伸びている状態で、手のひらが前方を向くジェスチャーを認識
public struct PeaceSignGesture: SingleHandGestureProtocol {
    
    public init() {}
    
    // MARK: - ジェスチャー識別情報
    
    public var gestureName: String { "ピースサイン" }
    public var priority: Int { 10 }
    public var category: GestureCategory { .counting }

    // MARK: - ジェスチャー検出実装
    
    /// ピースサインの条件を効率的に判定
    /// 早期リターンによるパフォーマンス最適化を適用
    public func matches(_ gestureData: SingleHandGestureData) -> Bool {
        // Step 1: Core finger configuration check (most selective condition)
        guard isCorrectFingerConfiguration(gestureData) else { return false }
        
        // Step 2: Finger orientation check
        guard areTargetFingersPointingUp(gestureData) else { return false }
        
        // Step 3: Palm orientation check
        guard isPalmFacingForward(gestureData) else { return false }
        
        return true
    }
    
    // MARK: - Private Helper Methods
    
    /// 人差し指と中指のみが伸びている状態かを判定
    private func isCorrectFingerConfiguration(_ gestureData: SingleHandGestureData) -> Bool {
        let requiredStraightFingers: [FingerType] = [.index, .middle]
        let requiredBentFingers: [FingerType] = [.thumb, .ring, .little]
        
        // Check straight fingers
        for finger in requiredStraightFingers {
            guard gestureData.isFingerStraight(finger) else { return false }
        }
        
        // Check bent fingers
        for finger in requiredBentFingers {
            guard gestureData.isFingerBent(finger) else { return false }
        }
        
        return true
    }
    
    /// 対象の指が上方向を向いているかを判定
    private func areTargetFingersPointingUp(_ gestureData: SingleHandGestureData) -> Bool {
        return gestureData.isFingerPointing(.index, direction: .top) &&
               gestureData.isFingerPointing(.middle, direction: .top)
    }
    
    /// 手のひらが前方向を向いているかを判定
    private func isPalmFacingForward(_ gestureData: SingleHandGestureData) -> Bool {
        return gestureData.isPalmFacing(.forward)
    }

    // MARK: - Protocol Default Implementation Overrides
    
    /// 人差し指と中指だけが伸びている状態を要求
    public var requiresOnlyIndexAndMiddleStraight: Bool { true }
    
    /// 指定した指の方向要件を定義
    public func requiresFingerPointing(_ finger: FingerType, direction: GestureDetectionDirection) -> Bool {
        let targetFingers: Set<FingerType> = [.index, .middle]
        return targetFingers.contains(finger) && direction == .top
    }
    
    /// 手のひらの方向要件を定義
    public func requiresPalmFacing(_ direction: GestureDetectionDirection) -> Bool {
        return direction == .forward
    }
}
