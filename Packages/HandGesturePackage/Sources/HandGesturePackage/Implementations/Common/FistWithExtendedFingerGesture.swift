//
//  FistWithExtendedFingerGesture.swift
//  HandGesturePackage
//
//  Created by Claude Code on 2025/08/02.
//

import Foundation
import HandGestureKit

/// 握り拳から特定の指を伸ばすジェスチャーの汎用実装
/// 手話のI（小指）などで使用される
public struct FistWithExtendedFingerGesture: SingleHandGestureProtocol {
    
    private let extendedFinger: FingerType
    private let gesturePattern: GestureBuilder
    private let customName: String
    
    public init(extendedFinger: FingerType, name: String) {
        self.extendedFinger = extendedFinger
        self.customName = name
        self.gesturePattern = CommonGesturePatterns.fistWithExtendedFinger(extendedFinger)
    }
    
    public var gestureName: String { customName }
    public var priority: Int { 5 }
    public var category: GestureCategory { .gesture }
    
    public func matches(_ gestureData: SingleHandGestureData) -> Bool {
        return gesturePattern.validate(gestureData)
    }
}