//
//  TwoHandsGestureProtocol.swift
//  HandGesturePackage
//
//  Created by Claude on 2025/07/26.
//

import Foundation

/// 両手ジェスチャーを定義するためのプロトコル
public protocol TwoHandsGestureProtocol: BaseGestureProtocol {

    /// 両手のジェスチャーデータがこのジェスチャーに一致するかを判定
    /// - Parameter gestureData: 両手のジェスチャーデータ
    /// - Returns: ジェスチャーが一致する場合はtrue
    func matches(_ gestureData: HandsGestureData) -> Bool
}

// MARK: - デフォルト実装
extension TwoHandsGestureProtocol {
    public var description: String {
        return gestureName
    }

    public var priority: Int {
        return 0
    }

    public var gestureType: GestureType {
        return .twoHand
    }
}
