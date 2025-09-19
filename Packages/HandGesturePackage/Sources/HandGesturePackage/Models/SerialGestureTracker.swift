//
//  SerialGestureTracker.swift
//  HandGesturePackage
//
//  Created by Yugo Sugiyama on 2025/08/07.
//

import Foundation
import HandGestureKit

/// シリアルジェスチャーの追跡状態を管理するクラス
public class SerialGestureTracker {

    // MARK: - Properties

    /// 現在追跡中のシリアルジェスチャー
    public private(set) var currentGesture: SerialGestureProtocol?

    /// 現在のジェスチャーインデックス
    public private(set) var currentIndex: Int = 0

    /// 最後にジェスチャーが検出された時刻
    public private(set) var lastDetectionTime: Date?

    /// 追跡開始時刻
    public private(set) var trackingStartTime: Date?

    /// 最後に完了した時刻(クールダウン用)
    public private(set) var lastCompletionTime: Date?

    /// クールダウン期間(秒)
    private let cooldownSeconds: TimeInterval = 2.0

    // MARK: - Initialization

    public init() {}

    // MARK: - Public Methods

    /// シリアルジェスチャーの追跡を開始
    /// - Parameter gesture: 追跡するシリアルジェスチャー
    public func startTracking(_ gesture: SerialGestureProtocol) {
        currentGesture = gesture
        currentIndex = 0
        lastDetectionTime = Date()
        trackingStartTime = Date()
    }

    /// 検出結果で状態を更新
    /// - Parameter result: シリアルジェスチャーの検出結果
    /// - Returns: 更新後の状態
    public func update(with result: SerialGestureDetectionResult) -> SerialGestureDetectionResult {
        switch result {
        case .progress(let newIndex, _, let gesture):
            // 進行中：インデックスを更新
            currentIndex = newIndex
            lastDetectionTime = Date()
            currentGesture = gesture
            return result

        case .completed:
            // 完了：クールダウン時刻を記録してリセット
            lastCompletionTime = Date()
            let completedResult = result
            reset()
            return completedResult

        case .timeout, .notMatched:
            // タイムアウトまたは不一致：リセット
            reset()
            return result
        }
    }

    /// タイムアウトをチェック
    /// - Returns: タイムアウトした場合はtrue
    public func isTimedOut() -> Bool {
        guard let gesture = currentGesture,
            let lastTime = lastDetectionTime
        else {
            return false
        }

        let elapsed = Date().timeIntervalSince(lastTime)
        let isTimeout = elapsed > gesture.intervalSeconds
        if isTimeout {
            HandGestureLogger.logDebug(
                "⏱️ タイムアウト検出: 経過時間=\(elapsed)秒 > 制限時間=\(gesture.intervalSeconds)秒")
        }
        return isTimeout
    }

    /// 残り時間を取得
    /// - Returns: 残り時間(秒)。追跡中でない場合は0
    public func timeRemaining() -> TimeInterval {
        guard let gesture = currentGesture,
            let lastTime = lastDetectionTime
        else {
            return 0
        }

        let elapsed = Date().timeIntervalSince(lastTime)
        let remaining = gesture.intervalSeconds - elapsed
        return max(0, remaining)
    }

    /// 追跡状態をリセット
    public func reset() {
        currentGesture = nil
        currentIndex = 0
        lastDetectionTime = nil
        trackingStartTime = nil
    }

    /// 追跡中かどうか
    public var isTracking: Bool {
        return currentGesture != nil && !isTimedOut()
    }

    /// 現在の進行状況(0.0〜1.0)
    public var progress: Float {
        guard let gesture = currentGesture else { return 0 }
        let total = gesture.gestures.count
        guard total > 0 else { return 0 }
        return Float(currentIndex) / Float(total)
    }

    /// 現在のステップの説明を取得
    public var currentStepDescription: String? {
        guard let gesture = currentGesture,
            currentIndex < gesture.stepDescriptions.count
        else {
            return nil
        }
        return gesture.stepDescriptions[currentIndex]
    }

    /// クールダウン中かどうか
    public func isInCooldown() -> Bool {
        guard let lastCompletion = lastCompletionTime else {
            return false
        }
        return Date().timeIntervalSince(lastCompletion) < cooldownSeconds
    }

    /// 完了したジェスチャーの同じものを検出しないようにするチェック
    public func shouldSkipGesture(_ gesture: SerialGestureProtocol) -> Bool {
        // クールダウン中で、かつ現在の追跡インデックスが最後のステップの場合のみスキップ
        // これにより、完了直後の重複検出を防ぎつつ、新しいシーケンスは開始可能
        if isInCooldown() && currentGesture != nil && currentIndex >= 1 {
            return true
        }
        return false
    }
}
