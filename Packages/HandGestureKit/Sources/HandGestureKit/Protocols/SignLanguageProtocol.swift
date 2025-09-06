//
//  SignLanguageProtocol.swift
//  HandGestureKit
//
//  Created by Yugo Sugiyama on 2025/07/30.
//

import Foundation

/// 手話ジェスチャーを定義するためのプロトコル
public protocol SignLanguageProtocol: SingleHandGestureProtocol {
    /// 手話が示す意味のテキスト
    var meaning: String { get }
}

/// デフォルト実装
extension SignLanguageProtocol {

    /// デフォルトの優先度(高めに設定して通常ジェスチャーより優先)
    public var priority: Int { 10 }
}
