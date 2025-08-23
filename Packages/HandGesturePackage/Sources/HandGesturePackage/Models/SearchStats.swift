//
//  SearchStats.swift
//  HandGesturePackage
//
//  Created by Yugo Sugiyama on 2025/07/27.
//

import Foundation

/// ジェスチャー検索の統計情報
public struct SearchStats {
    /// 検索実行回数
    public var searchCount = 0

    /// チェックしたジェスチャー総数
    public var gesturesChecked = 0

    /// 見つかったマッチ総数
    public var matchesFound = 0

    /// 総検索時間(秒)
    public var totalSearchTime = 0.0

    /// 平均検索時間(秒)
    public var averageSearchTime: TimeInterval {
        return searchCount > 0 ? totalSearchTime / Double(searchCount) : 0.0
    }

    /// 平均チェック効率(マッチ率)
    public var matchRate: Double {
        return gesturesChecked > 0 ? Double(matchesFound) / Double(gesturesChecked) : 0.0
    }

    public init() {}
}

// MARK: - Formatting Extensions

extension SearchStats {
    /// フォーマットされた統計情報を取得
    public var formattedSummary: String {
        """
        検索数: \(searchCount)
        チェック数: \(gesturesChecked)
        マッチ数: \(matchesFound)
        平均時間: \(String(format: "%.3f", averageSearchTime * 1000))ms
        マッチ率: \(String(format: "%.1f", matchRate * 100))%
        """
    }

    /// パフォーマンスレベルを判定
    public enum PerformanceLevel {
        case excellent  // < 5ms
        case good  // < 10ms
        case fair  // < 20ms
        case poor  // >= 20ms

        var description: String {
            switch self {
            case .excellent: return "優秀"
            case .good: return "良好"
            case .fair: return "普通"
            case .poor: return "要改善"
            }
        }
    }

    /// 現在のパフォーマンスレベル
    public var performanceLevel: PerformanceLevel {
        let avgTimeMs = averageSearchTime * 1000
        if avgTimeMs < 5 {
            return .excellent
        } else if avgTimeMs < 10 {
            return .good
        } else if avgTimeMs < 20 {
            return .fair
        } else {
            return .poor
        }
    }
}
