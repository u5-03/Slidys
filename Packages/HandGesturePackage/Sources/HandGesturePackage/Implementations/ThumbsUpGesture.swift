//
//  ThumbsUpGesture.swift
//  HandGesturePackage
//
//  Created by Claude Code on 2025/07/24.
//

import Foundation
import RealityKit
import HandGestureKit

/// サムズアップジェスチャーの実装例
public struct ThumbsUpGesture: SingleHandGestureProtocol {
    
    private static let gesturePattern = CommonGesturePatterns.thumbsUp()
    
    public init() {}
    
    public var gestureName: String { "サムズアップ" }
    public var priority: Int { 15 }
    public var category: GestureCategory { .gesture }
    
    public func matches(_ gestureData: SingleHandGestureData) -> Bool {
        return Self.gesturePattern.validate(gestureData)
    }
    
    public var requiresOnlyThumbStraight: Bool { true }
    
    public func requiresFingerPointing(_ finger: FingerType, direction: GestureDetectionDirection) -> Bool {
        return finger == .thumb && direction == .top
    }
}
