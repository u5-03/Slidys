//
//  BaseGestureProtocol.swift
//  HandGesturePackage
//
//  Created by Yugo Sugiyama on 2025/07/26.
//

import Foundation

/// ジェスチャーのカテゴリ分類（検索効率化のため）
public enum GestureCategory: CaseIterable {
    case pointing        // 指差し系（人差し指、ポインティング）
    case counting        // 数字系（ピースサイン、3本指など）
    case hand            // 手全体系（握り拳、パーなど）
    case gesture         // 特殊ジェスチャー（サムズアップ、OKサインなど）
    case custom          // カスタムジェスチャー
}

/// すべてのジェスチャーの基底となるプロトコル
public protocol BaseGestureProtocol {
    /// ジェスチャーの一意識別子
    var id: String { get }
    
    /// ジェスチャーの表示名
    var displayName: String { get }
    
    /// ジェスチャーの名前（識別用）
    var gestureName: String { get }
    
    /// ジェスチャーの説明
    var description: String { get }
    
    /// ジェスチャーの優先度（小さい値ほど高優先度）
    var priority: Int { get }
    
    /// ジェスチャーのカテゴリ
    var category: GestureCategory { get }
    
    /// ジェスチャータイプ（片手/両手）
    var gestureType: GestureType { get }
}

/// ジェスチャーの種類
public enum GestureType {
    case singleHand
    case twoHand
}

/// ジェスチャー検出結果
public enum GestureDetectionResult {
    case success([DetectedGesture])
    case failure(GestureDetectionError)
}

/// 検出されたジェスチャー情報
public struct DetectedGesture {
    public let gesture: BaseGestureProtocol
    public let confidence: Float
    public let metadata: [String: Any]
    
    public init(gesture: BaseGestureProtocol, confidence: Float = 1.0, metadata: [String: Any] = [:]) {
        self.gesture = gesture
        self.confidence = confidence
        self.metadata = metadata
    }
}

/// ジェスチャー検出エラー
public enum GestureDetectionError: Error, LocalizedError {
    case noHandDataAvailable
    case invalidHandData(String)
    case processingError(String)
    case timeout
    
    public var errorDescription: String? {
        switch self {
        case .noHandDataAvailable:
            return "手のデータが利用できません"
        case .invalidHandData(let detail):
            return "無効な手のデータ: \(detail)"
        case .processingError(let detail):
            return "処理エラー: \(detail)"
        case .timeout:
            return "タイムアウトが発生しました"
        }
    }
}

/// デフォルト実装
public extension BaseGestureProtocol {
    /// デフォルトのid実装（型名を使用）
    var id: String {
        // 型名からモジュール名を除去してIDとして使用
        let fullTypeName = String(describing: type(of: self))
        return fullTypeName.split(separator: ".").last.map(String.init) ?? fullTypeName
    }
    
    /// デフォルトのdisplayName実装（gestureNameを使用）
    var displayName: String {
        return gestureName
    }
    
    var description: String {
        return gestureName
    }
    
    var category: GestureCategory {
        return .custom
    }
}
