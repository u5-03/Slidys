//
//  SerialGestureProtocol.swift
//  HandGestureKit
//
//  Created by Yugo Sugiyama on 2025/08/07.
//

import Foundation

/// 連続的な動作を持つジェスチャーを定義するプロトコル
/// 複数のジェスチャーを順番に検出することで、モーションのあるジェスチャーを表現
public protocol SerialGestureProtocol: SignLanguageProtocol {
    /// 順番に検出すべきジェスチャーの配列
    var gestures: [BaseGestureProtocol] { get }
    
    /// ジェスチャー間の最大許容時間（秒）
    var intervalSeconds: TimeInterval { get }
    
    /// 各ステップの説明（UI表示用）
    var stepDescriptions: [String] { get }
}

/// デフォルト実装
public extension SerialGestureProtocol {
    /// デフォルトのカテゴリは手話
    var category: GestureCategory { .custom }
    
    /// デフォルトの優先度（高めに設定）
    var priority: Int { 5 }
    
    /// デフォルトのインターバル（1秒）
    var intervalSeconds: TimeInterval { 1.0 }
    
    /// デフォルトのジェスチャータイプ（シリアルジェスチャーは通常両手）
    var gestureType: GestureType { .twoHand }
    
    /// SingleHandGestureProtocolのmatches実装（使用しない）
    func matches(_ gestureData: SingleHandGestureData) -> Bool {
        // SerialGestureProtocolは個別のmatchesメソッドを使用しない
        // 代わりにgesturesプロパティの各要素が順番にマッチングされる
        return false
    }
}