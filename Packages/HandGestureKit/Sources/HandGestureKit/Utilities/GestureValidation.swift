//
//  GestureValidation.swift
//  HandGesturePackage
//
//  Created by Claude Code on 2025/07/24.
//

import Foundation

/// ジェスチャー検出で頻繁に使用される共通パターンを提供するユーティリティ
public enum GestureValidation {
    
    // MARK: - Finger Configuration Patterns
    
    /// 指定した指の組み合わせが正しい状態（伸びている/曲がっている）かを検証
    /// - Parameters:
    ///   - gestureData: 手のジェスチャーデータ
    ///   - straightFingers: 伸びている必要がある指の配列
    ///   - bentFingers: 曲がっている必要がある指の配列
    /// - Returns: 条件を満たす場合true
    public static func validateFingerConfiguration(
        _ gestureData: SingleHandGestureData,
        straight straightFingers: [FingerType],
        bent bentFingers: [FingerType]
    ) -> Bool {
        // Check straight fingers
        for finger in straightFingers {
            guard gestureData.isFingerStraight(finger) else { return false }
        }
        
        // Check bent fingers
        for finger in bentFingers {
            guard gestureData.isFingerBent(finger) else { return false }
        }
        
        return true
    }
    
    /// 指定した指のみが伸びていて、他の指が曲がっているかを検証
    /// - Parameters:
    ///   - gestureData: 手のジェスチャーデータ
    ///   - targetFingers: 伸びている必要がある指の配列
    /// - Returns: 条件を満たす場合true
    public static func validateOnlyTargetFingersStraight(
        _ gestureData: SingleHandGestureData,
        targetFingers: [FingerType]
    ) -> Bool {
        let allFingers = FingerType.allCases
        let targetSet = Set(targetFingers)
        let otherFingers = allFingers.filter { !targetSet.contains($0) }
        
        return validateFingerConfiguration(
            gestureData,
            straight: targetFingers,
            bent: otherFingers
        )
    }
    
    // MARK: - Direction Validation
    
    /// 指定した指が全て同じ方向を向いているかを検証
    /// - Parameters:
    ///   - gestureData: 手のジェスチャーデータ
    ///   - fingers: 検証対象の指配列
    ///   - direction: 期待する方向
    /// - Returns: 全ての指が指定方向を向いている場合true
    public static func validateFingersPointingInDirection(
        _ gestureData: SingleHandGestureData,
        fingers: [FingerType],
        direction: GestureDetectionDirection
    ) -> Bool {
        return fingers.allSatisfy { finger in
            gestureData.isFingerPointing(finger, direction: direction)
        }
    }
    
    // MARK: - Complex Gesture Patterns
    
    /// 握り拳の状態を検証
    /// - Parameter gestureData: 手のジェスチャーデータ
    /// - Returns: 握り拳状態の場合true
    public static func validateFistGesture(_ gestureData: SingleHandGestureData) -> Bool {
        return FingerType.allCases.allSatisfy { finger in
            gestureData.isFingerBent(finger)
        }
    }
    
    /// 開いた手（パー）の状態を検証
    /// - Parameter gestureData: 手のジェスチャーデータ
    /// - Returns: 開いた手の状態の場合true
    public static func validateOpenHandGesture(_ gestureData: SingleHandGestureData) -> Bool {
        return FingerType.allCases.allSatisfy { finger in
            gestureData.isFingerStraight(finger)
        }
    }
    
    /// 指差しジェスチャーの状態を検証（人差し指のみ伸びている）
    /// - Parameter gestureData: 手のジェスチャーデータ
    /// - Returns: 指差し状態の場合true
    public static func validatePointingGesture(_ gestureData: SingleHandGestureData) -> Bool {
        return validateOnlyTargetFingersStraight(
            gestureData,
            targetFingers: [.index]
        )
    }
}