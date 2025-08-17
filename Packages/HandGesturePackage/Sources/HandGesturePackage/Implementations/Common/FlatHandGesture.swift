//
//  FlatHandGesture.swift
//  HandGesturePackage
//
//  Created by Claude Code on 2025/08/02.
//

import Foundation
import HandGestureKit

/// 平らな手のジェスチャーの汎用実装
/// 4本の指を揃えて伸ばし、親指は手のひらに添える
/// 手話のBなどで使用される
public struct FlatHandGesture: SingleHandGestureProtocol {
    
    private static let gesturePattern = CommonGesturePatterns.flatHand()
    private let customName: String
    
    public init(name: String = "平らな手") {
        self.customName = name
    }
    
    public var gestureName: String { customName }
    public var priority: Int { 5 }
    public var category: GestureCategory { .hand }
    
    public func matches(_ gestureData: SingleHandGestureData) -> Bool {
        return Self.gesturePattern.validate(gestureData)
    }
}