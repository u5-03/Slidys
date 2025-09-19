//
//  ExtendedFingersGesture.swift
//  HandGesturePackage
//
//  Created by Claude Code on 2025/08/02.
//

import Foundation
import HandGestureKit

/// 複数の指を伸ばすジェスチャーの汎用実装
/// 手話のW(3本指)、L(親指と人差し指)などで使用される
public struct ExtendedFingersGesture: SingleHandGestureProtocol {

    private let extendedFingers: [FingerType]
    private let gesturePattern: GestureBuilder
    private let customName: String

    public init(extendedFingers: [FingerType], name: String) {
        self.extendedFingers = extendedFingers
        self.customName = name

        // 配列を個別の引数に展開する別の方法を使用
        let allFingers: [FingerType] = [.thumb, .index, .middle, .ring, .little]
        let bentFingers = allFingers.filter { !extendedFingers.contains($0) }

        var builder = GestureBuilder()

        // 伸ばす指を設定
        for finger in extendedFingers {
            builder = builder.withStraightFingers(finger)
        }

        // 曲げる指を設定
        for finger in bentFingers {
            builder = builder.withBentFingers(finger)
        }

        self.gesturePattern = builder
    }

    public var gestureName: String { customName }
    public var priority: Int { 5 }

    public func matches(_ gestureData: SingleHandGestureData) -> Bool {
        return gesturePattern.validate(gestureData)
    }
}
