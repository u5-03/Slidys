//
//  GestureBuilder.swift
//  HandGesturePackage
//
//  Created by Claude Code on 2025/07/24.
//

import Foundation

/// ジェスチャー定義を構築するためのビルダーパターン
public struct GestureBuilder {
    
    // MARK: - Properties
    
    private var requiredStraightFingers: [FingerType] = []
    private var requiredBentFingers: [FingerType] = []
    private var requiredFingerDirections: [(FingerType, GestureDetectionDirection)] = []
    private var requiredPalmDirection: GestureDetectionDirection?
    private var requiredArmDirection: GestureDetectionDirection?
    private var requiredFingerBendLevels: [(FingerType, SingleHandGestureData.FingerBendLevel, Bool)] = []
    private var requiredFingerContacts: [(FingerType, FingerType, Float)] = []
    
    public init() {}
    
    // MARK: - Builder Methods
    
    /// 伸びている必要がある指を追加
    public func withStraightFingers(_ fingers: FingerType...) -> GestureBuilder {
        var builder = self
        builder.requiredStraightFingers.append(contentsOf: fingers)
        return builder
    }
    
    /// 曲がっている必要がある指を追加
    public func withBentFingers(_ fingers: FingerType...) -> GestureBuilder {
        var builder = self
        builder.requiredBentFingers.append(contentsOf: fingers)
        return builder
    }
    
    /// 指の方向要件を追加
    public func withFingerPointing(_ finger: FingerType, direction: GestureDetectionDirection) -> GestureBuilder {
        var builder = self
        builder.requiredFingerDirections.append((finger, direction))
        return builder
    }
    
    /// 手のひらの方向要件を設定
    public func withPalmFacing(_ direction: GestureDetectionDirection) -> GestureBuilder {
        var builder = self
        builder.requiredPalmDirection = direction
        return builder
    }
    
    /// 腕の方向要件を設定
    public func withArmExtendedIn(_ direction: GestureDetectionDirection) -> GestureBuilder {
        var builder = self
        builder.requiredArmDirection = direction
        return builder
    }
    
    /// 指の曲がり具合レベルで要件を設定
    public func withBentFingersAtLevel(_ fingers: [FingerType], level: SingleHandGestureData.FingerBendLevel, minimumLevel: Bool = false) -> GestureBuilder {
        var builder = self
        builder.requiredFingerBendLevels.append(contentsOf: fingers.map { ($0, level, minimumLevel) })
        return builder
    }
    
    /// 指の接触要件を設定
    public func withFingersTouching(_ finger1: FingerType, _ finger2: FingerType, threshold: Float = 0.03) -> GestureBuilder {
        var builder = self
        builder.requiredFingerContacts.append((finger1, finger2, threshold))
        return builder
    }
    
    /// 複数の指を同時に伸ばす要件を設定（可変長引数版）
    public func withExtendedFingers(_ fingers: FingerType...) -> GestureBuilder {
        var builder = self
        builder.requiredStraightFingers.append(contentsOf: fingers)
        return builder
    }
    
    // MARK: - Validation
    
    /// 構築した条件でジェスチャーデータを検証
    /// - Parameter gestureData: 検証対象のジェスチャーデータ
    /// - Returns: 全ての条件を満たす場合true
    public func validate(_ gestureData: SingleHandGestureData) -> Bool {
        // Finger configuration validation
        guard GestureValidation.validateFingerConfiguration(
            gestureData,
            straight: requiredStraightFingers,
            bent: requiredBentFingers
        ) else { return false }
        
        // Finger direction validation
        for (finger, direction) in requiredFingerDirections {
            guard gestureData.isFingerPointing(finger, direction: direction) else {
                return false
            }
        }
        
        // Palm direction validation
        if let palmDirection = requiredPalmDirection {
            guard gestureData.isPalmFacing(palmDirection) else { return false }
        }
        
        // Arm direction validation
        if let armDirection = requiredArmDirection {
            guard gestureData.isArmExtendedInDirection(armDirection) else { return false }
        }
        
        // Finger bend level validation
        for (finger, level, isMinimum) in requiredFingerBendLevels {
            if isMinimum {
                guard gestureData.isFingerBentAtLeast(finger, minimumLevel: level) else { return false }
            } else {
                guard gestureData.isFingerAtBendLevel(finger, level: level) else { return false }
            }
        }
        
        // Finger contact validation
        for (finger1, finger2, threshold) in requiredFingerContacts {
            guard gestureData.handTrackingComponent.areFingerTipsTouching(finger1, finger2, threshold: threshold) else { return false }
        }
        
        return true
    }
}