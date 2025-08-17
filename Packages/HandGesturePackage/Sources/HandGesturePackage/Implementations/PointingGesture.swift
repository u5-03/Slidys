//
//  PointingGesture.swift
//  HandGesturePackage
//
//  Created by Claude Code on 2025/07/24.
//

import Foundation
import RealityKit
import HandGestureKit

/// 指差しジェスチャーの実装例
public struct PointingGesture: SingleHandGestureProtocol {
    
    private static let gesturePattern = CommonGesturePatterns.pointing()
    
    public init() {}
    
    public var gestureName: String { "指差し" }
    public var priority: Int { 5 }
    public var category: GestureCategory { .pointing }
    
    public func matches(_ gestureData: SingleHandGestureData) -> Bool {
        return Self.gesturePattern.validate(gestureData)
    }
    
    public var requiresOnlyIndexFingerStraight: Bool { true }
}
