//
//  SerialGestureDetectionResult.swift
//  HandGestureKit
//
//  Created by Yugo Sugiyama on 2025/08/07.
//

import Foundation

/// シリアルジェスチャーの検出結果を表す列挙型
public enum SerialGestureDetectionResult {
    /// 進行中(現在のインデックスと全体のジェスチャー数を含む)
    case progress(currentIndex: Int, totalGestures: Int, gesture: SerialGestureProtocol)

    /// 完了(すべてのジェスチャーがマッチした)
    case completed(gesture: SerialGestureProtocol)

    /// タイムアウト(インターバルを超過した)
    case timeout

    /// マッチしない(現在のジェスチャーが期待と異なる)
    case notMatched

    /// 進行状況のパーセンテージを取得
    public var progressPercentage: Float {
        switch self {
        case .progress(let current, let total, _):
            guard total > 0 else { return 0 }
            return Float(current) / Float(total)
        case .completed:
            return 1.0
        default:
            return 0
        }
    }

    /// 現在のステップ番号を取得(1ベース)
    public var currentStep: Int {
        switch self {
        case .progress(let current, _, _):
            return current + 1
        case .completed(let gesture):
            return gesture.gestures.count
        default:
            return 0
        }
    }

    /// 総ステップ数を取得
    public var totalSteps: Int {
        switch self {
        case .progress(_, let total, _):
            return total
        case .completed(let gesture):
            return gesture.gestures.count
        default:
            return 0
        }
    }
}
