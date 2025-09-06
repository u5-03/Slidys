//
//  ImprovedPeaceSignGesture.swift
//  HandGesturePackage
//
//  Created by Claude Code on 2025/07/24.
//

import Foundation
import HandGestureKit
import RealityKit

/// ユーティリティクラスを活用した改良版ピースサインジェスチャー
/// 可読性とメンテナンス性を向上させた実装例
public struct ImprovedPeaceSignGesture: SingleHandGestureProtocol {

    // MARK: - Static Configuration

    /// ジェスチャー構成の定義(再利用可能)
    private static let gesturePattern = CommonGesturePatterns.peaceSign()

    public init() {}

    // MARK: - Protocol Implementation

    public var gestureName: String { "改良版ピースサイン" }
    public var priority: Int { 9 }  // Original より少し高い優先度

    // MARK: - Optimized Matching Implementation

    /// ユーティリティクラスを使用した効率的なマッチング
    public func matches(_ gestureData: SingleHandGestureData) -> Bool {
        return Self.gesturePattern.validate(gestureData)
    }

    // MARK: - Protocol Default Overrides

    public var requiresOnlyIndexAndMiddleStraight: Bool { true }

    public func requiresFingerPointing(_ finger: FingerType, direction: GestureDetectionDirection)
        -> Bool
    {
        let targetFingers: Set<FingerType> = [.index, .middle]
        return targetFingers.contains(finger) && direction == .top
    }

    public func requiresPalmFacing(_ direction: GestureDetectionDirection) -> Bool {
        return direction == .forward
    }
}
