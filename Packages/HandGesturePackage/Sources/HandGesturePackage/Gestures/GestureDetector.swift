//
//  GestureDetector.swift
//  HandGesturePackage
//
//  Created by Yugo Sugiyama on 2025/07/26.
//

import ARKit
import Foundation
import HandGestureKit
import RealityKit

/// 統合ジェスチャー検出システム
/// 片手・両手のジェスチャーを統一的に検出する
public class GestureDetector {

    // MARK: - Properties

    /// 登録されたジェスチャー(優先度順)
    private var sortedGestures: [BaseGestureProtocol] = []


    /// ジェスチャータイプ別のインデックス
    private var typeIndex: [GestureType: [Int]] = [:]

    /// 検索統計情報
    public private(set) var searchStats = SearchStats()

    // MARK: - Initialization

    public init(gestures: [BaseGestureProtocol] = []) {
        registerGestures(gestures)
    }

    // MARK: - Registration

    /// ジェスチャーを登録
    public func registerGestures(_ gestures: [BaseGestureProtocol]) {
        // 優先度順にソート
        sortedGestures = gestures.sorted { $0.priority < $1.priority }

        // インデックスを構築
        buildIndices()

        HandGestureLogger.logGesture("🎯 UnifiedGestureDetector: \(gestures.count)個のジェスチャーを登録")
        logGestureInfo()
    }

    /// ジェスチャーを追加
    public func addGesture(_ gesture: BaseGestureProtocol) {
        sortedGestures.append(gesture)
        registerGestures(sortedGestures)
    }

    // MARK: - Detection Methods

    /// HandTrackingComponentの配列からジェスチャーを検出
    public func detectGestures(
        from handEntities: [Entity],
        targetGestures: [BaseGestureProtocol]? = nil
    ) -> GestureDetectionResult {
        let startTime = CFAbsoluteTimeGetCurrent()
        searchStats.searchCount += 1

        // エンティティからHandTrackingComponentを抽出
        var leftHandComponent: HandTrackingComponent?
        var rightHandComponent: HandTrackingComponent?

        for entity in handEntities {
            guard let handComponent = entity.components[HandTrackingComponent.self] else {
                continue
            }

            // 手のデータが有効かチェック
            if let wrist = handComponent.fingers[.wrist] {
                let wristPos = wrist.position(relativeTo: nil)
                if wristPos.x == 0 && wristPos.y == 0 && wristPos.z == 0 {
                    continue
                }
            }

            if handComponent.chirality == .left {
                leftHandComponent = handComponent
            } else {
                rightHandComponent = handComponent
            }
        }

        // 手のデータがない場合
        guard leftHandComponent != nil || rightHandComponent != nil else {
            return .failure(.noHandDataAvailable)
        }

        // ジェスチャーデータを作成
        let leftGestureData = leftHandComponent.map {
            SingleHandGestureData(handTrackingComponent: $0, handKind: .left)
        }
        let rightGestureData = rightHandComponent.map {
            SingleHandGestureData(handTrackingComponent: $0, handKind: .right)
        }

        let handsGestureData: HandsGestureData?
        if let left = leftGestureData, let right = rightGestureData {
            handsGestureData = HandsGestureData(leftHand: left, rightHand: right)
        } else {
            handsGestureData = nil
        }

        // 検出実行
        let gesturesToCheck = targetGestures ?? sortedGestures
        var detectedGestures: [DetectedGesture] = []

        for gesture in gesturesToCheck {
            searchStats.gesturesChecked += 1

            let matches: Bool
            let confidence: Float = 1.0
            var metadata: [String: Any] = [:]

            switch gesture.gestureType {
            case .singleHand:
                if let singleGesture = gesture as? SingleHandGestureProtocol {
                    // 左右どちらかの手で一致するかチェック
                    let leftMatches = leftGestureData.map { singleGesture.matches($0) } ?? false
                    let rightMatches = rightGestureData.map { singleGesture.matches($0) } ?? false

                    // 左手がマッチした場合
                    if leftMatches {
                        var leftMetadata = metadata
                        leftMetadata["detectedHand"] = "left"
                        detectedGestures.append(
                            DetectedGesture(
                                gesture: gesture,
                                confidence: confidence,
                                metadata: leftMetadata
                            ))
                        searchStats.matchesFound += 1
                    }

                    // 右手がマッチした場合
                    if rightMatches {
                        var rightMetadata = metadata
                        rightMetadata["detectedHand"] = "right"
                        detectedGestures.append(
                            DetectedGesture(
                                gesture: gesture,
                                confidence: confidence,
                                metadata: rightMetadata
                            ))
                        searchStats.matchesFound += 1
                    }

                    // どちらもマッチしなかった場合のフラグ
                    matches = false  // 後続の処理でスキップするため
                } else {
                    matches = false
                }

            case .twoHand:
                if let twoHandGesture = gesture as? TwoHandsGestureProtocol,
                    let hands = handsGestureData
                {
                    matches = twoHandGesture.matches(hands)

                    if matches {
                        metadata["palmDistance"] = hands.palmCenterDistance
                        metadata["areFacingEachOther"] = hands.arePalmsFacingEachOther
                    }
                } else {
                    matches = false
                }
            }

            // 片手ジェスチャーは個別に追加済みなので、それ以外のジェスチャーのみ追加
            if matches && gesture.gestureType != .singleHand {
                detectedGestures.append(
                    DetectedGesture(
                        gesture: gesture,
                        confidence: confidence,
                        metadata: metadata
                    ))
                searchStats.matchesFound += 1
            }
        }

        let endTime = CFAbsoluteTimeGetCurrent()
        searchStats.totalSearchTime += (endTime - startTime)

        return .success(detectedGestures)
    }


    // MARK: - Utility Methods

    /// 検索統計をリセット
    public func resetSearchStats() {
        searchStats = SearchStats()
    }

    /// 登録されているジェスチャー情報を取得
    public func getRegisteredGesturesInfo() -> [String: Any] {
        var info: [String: Any] = [:]
        info["totalGestures"] = sortedGestures.count

        // タイプ別カウント
        var typeCount: [String: Int] = [:]
        typeCount["singleHand"] = typeIndex[.singleHand]?.count ?? 0
        typeCount["twoHand"] = typeIndex[.twoHand]?.count ?? 0
        info["typeCounts"] = typeCount

        return info
    }

    // MARK: - Private Methods

    /// インデックスを構築
    private func buildIndices() {
        typeIndex.removeAll()

        for (index, gesture) in sortedGestures.enumerated() {
            // タイプインデックス
            if typeIndex[gesture.gestureType] == nil {
                typeIndex[gesture.gestureType] = []
            }
            typeIndex[gesture.gestureType]?.append(index)
        }
    }


    /// ジェスチャー情報をログ出力
    private func logGestureInfo() {
        // タイプ別
        HandGestureLogger.logDebug("  🤚 片手: \(typeIndex[.singleHand]?.count ?? 0)個")
        HandGestureLogger.logDebug("  🙌 両手: \(typeIndex[.twoHand]?.count ?? 0)個")
    }

    /// シリアルジェスチャーの検出(ステートレス)
    /// - Parameters:
    ///   - handEntities: 手のエンティティ配列
    ///   - serialGesture: 検出対象のシリアルジェスチャー
    ///   - currentIndex: 現在チェックすべきジェスチャーのインデックス
    /// - Returns: シリアルジェスチャーの検出結果
    public func detectSerialGesture(
        from handEntities: [Entity],
        serialGesture: SerialGestureProtocol,
        currentIndex: Int
    ) -> SerialGestureDetectionResult {
        // インデックスの妥当性チェック
        guard currentIndex >= 0 && currentIndex < serialGesture.gestures.count else {
            return .notMatched
        }

        // 現在のステップのジェスチャーを取得
        let currentGesture = serialGesture.gestures[currentIndex]

        HandGestureLogger.logDebug(
            "🔍 シリアルジェスチャー検出: \(serialGesture.gestureName) - ステップ \(currentIndex)/\(serialGesture.gestures.count - 1)"
        )

        // 既存のdetectGesturesメソッドを使用して検出
        let result = detectGestures(from: handEntities, targetGestures: [currentGesture])

        switch result {
        case .success(let detectedGestures):
            if !detectedGestures.isEmpty {
                // 現在のジェスチャーがマッチした
                if currentIndex == serialGesture.gestures.count - 1 {
                    // すべてのジェスチャーが完了
                    HandGestureLogger.logDebug("🎉 シリアルジェスチャー完了: \(serialGesture.gestureName)")
                    return .completed(gesture: serialGesture)
                } else {
                    // まだ続きがある
                    HandGestureLogger.logDebug("➡️ 次のステップへ: \(currentIndex + 1)")
                    return .progress(
                        currentIndex: currentIndex + 1,
                        totalGestures: serialGesture.gestures.count,
                        gesture: serialGesture
                    )
                }
            } else {
                // 現在のジェスチャーがマッチしなかった
                return .notMatched
            }
        case .failure:
            // エラーが発生した場合はマッチしないとみなす
            return .notMatched
        }
    }
}

// MARK: - Convenience Extensions

extension GestureDetector {

    /// 高優先度ジェスチャーのみを検出
    public func detectHighPriorityGestures(
        from handEntities: [Entity],
        priorityThreshold: Int = 100
    ) -> GestureDetectionResult {
        let highPriorityGestures = sortedGestures.filter { $0.priority <= priorityThreshold }
        return detectGestures(from: handEntities, targetGestures: highPriorityGestures)
    }
}
