//
//  HandGestureTrackingSystem.swift
//  HandGesturePackage
//
//  Created by Yugo Sugiyama on 2024/12/10.
//

import ARKit
import Foundation
import HandGestureKit
import RealityKit
import SwiftUI
import simd

/// ハンドジェスチャートラッキングシステム
public struct HandGestureTrackingSystem: System {

    // MARK: - Static Properties

    /// 共有GestureInfoStoreへの参照
    /// RealityKitがSystemを自動的にインスタンス化するため、
    /// 依存性はこの方法で注入する
    /// 弱参照にして循環参照を防ぐ
    private static weak var sharedGestureInfoStore: GestureInfoStore?

    /// GestureInfoStoreを設定するメソッド
    public static func setGestureInfoStore(_ store: GestureInfoStore) {
        sharedGestureInfoStore = store
    }

    // MARK: - Instance Properties

    /// 統合ジェスチャー検出器
    private let unifiedDetector: GestureDetector

    /// 検出対象ジェスチャー
    public var targetGestures: [BaseGestureProtocol]?

    /// すべての利用可能なジェスチャー
    private let allGestures: [BaseGestureProtocol]

    /// シリアルジェスチャートラッカー
    private var serialGestureTracker = SerialGestureTracker()

    /// すべてのシリアルジェスチャー
    private let serialGestures: [SerialGestureProtocol]

    private let handTrackingComponentQuery = EntityQuery(where: .has(HandTrackingComponent.self))

    // MARK: - System Lifecycle

    public init(scene: RealityKit.Scene) {
        // すべてのジェスチャーを保存
        self.allGestures = AvailableGestures.allGestureInstances

        // シリアルジェスチャーを抽出
        self.serialGestures = AvailableGestures.allSerialGestureInstances

        // 統合ジェスチャー検出器を初期化
        self.unifiedDetector = GestureDetector(gestures: allGestures)
    }

    public func update(context: SceneUpdateContext) {
        HandGestureLogger.logDebug("🔄 HandGestureTrackingSystem.update() called")
        
        let handEntities = context.scene.performQuery(handTrackingComponentQuery)
        
        // シリアルジェスチャーの処理
        processSerialGestures(handEntities: Array(handEntities))

        // GestureInfoStoreから有効なジェスチャーをフィルタリング
        var filteredGestures: [BaseGestureProtocol]? = nil
        if let gestureInfoStore = Self.sharedGestureInfoStore {
            HandGestureLogger.logDebug("📊 GestureInfoStore available, filtering gestures")
            // 手話モードが有効かどうかで使用するジェスチャーを切り替え
            if gestureInfoStore.isHandLanguageDetectionEnabled {
                // 手話モード: 手話ジェスチャーのみを使用(シリアルジェスチャーを除く)
                filteredGestures = AvailableGestures.allSignLanguageInstances.filter { gesture in
                    !(gesture is SerialGestureProtocol)
                }
            } else {
                // 通常モード: 有効なジェスチャーをフィルタリング
                // デバッグ: 有効なジェスチャーIDのセットを出力
                // HandGestureLogger.logDebug("有効なジェスチャーID: \(gestureInfoStore.enabledGestureIds)")

                filteredGestures = allGestures.filter { gesture in
                    let isEnabled = gestureInfoStore.enabledGestureIds.contains(gesture.id)

                    // デバッグ: 各ジェスチャーのフィルタリング結果を出力
                    // HandGestureLogger.logDebug("\(gesture.displayName) (ID: \(gesture.id)): \(isEnabled ? "有効" : "無効")")

                    return isEnabled
                }

                // HandGestureLogger.logDebug("フィルタリング後のジェスチャー数: \(filteredGestures?.count ?? 0)")
            }
        } else {
            HandGestureLogger.logDebug("⚠️ GestureInfoStore が設定されていません")
        }

        // 統合ジェスチャー検出器を使用
        let result = unifiedDetector.detectGestures(
            from: Array(handEntities),
            targetGestures: filteredGestures ?? targetGestures
        )

        // 検出結果を処理
        switch result {
        case .success(let detectedGestures):
            HandGestureLogger.logDebug("✅ Gesture detection successful: \(detectedGestures.count) gestures detected")
            processDetectedGestures(detectedGestures, handEntities: Array(handEntities))
        case .failure(let error):
            HandGestureLogger.logDebug("❌ Gesture detection failed: \(error)")
            handleDetectionError(error)
        }

        // 個別の手の状態を更新
        updateHandStates(from: Array(handEntities))
    }
}

// MARK: - Gesture Processing

extension HandGestureTrackingSystem {

    /// 検出されたジェスチャーを処理
    fileprivate func processDetectedGestures(
        _ detectedGestures: [DetectedGesture], handEntities: [Entity]
    ) {
        guard let gestureInfoStore = Self.sharedGestureInfoStore else { return }

        var debugMessages: [String] = []

        // 検出されたジェスチャーを処理
        for detected in detectedGestures {
            let gesture = detected.gesture

            switch gesture.gestureType {
            case .singleHand:
                if let hand = detected.metadata["detectedHand"] as? String {
                    debugMessages.append("\(hand == "left" ? "左手" : "右手"): \(gesture.gestureName)")
                }

            case .twoHand:
                if let distance = detected.metadata["palmDistance"] as? Float {
                    debugMessages.append(
                        "両手: \(gesture.gestureName) (距離: \(String(format: "%.2f", distance * 100))cm)"
                    )
                } else {
                    debugMessages.append("両手: \(gesture.gestureName)")
                }
            }
        }

        // 手話モードの特別な処理
        if gestureInfoStore.isHandLanguageDetectionEnabled {
            processSignLanguageGestures(detectedGestures, gestureInfoStore: gestureInfoStore)
        }

        // ジェスチャーストアを更新
        gestureInfoStore.updateDetectedGestures(detectedGestures)
        if !debugMessages.isEmpty {
            gestureInfoStore.updateDebugInfo(debugMessages.joined(separator: "\n"))
        }

        // 手の色を更新
        updateHandColors(detectedGestures: detectedGestures, handEntities: handEntities)

        // パフォーマンス統計を更新
        updatePerformanceStats(detectedGestures)
    }

    /// エラーハンドリング
    fileprivate func handleDetectionError(_ error: GestureDetectionError) {
        // noHandDataAvailable は頻繁に発生するため、ログに出力しない
        switch error {
        case .noHandDataAvailable:
            // 手のデータがない場合は静かに処理(ログ出力なし)
            break
        default:
            HandGestureLogger.logError("ジェスチャー検出エラー", error: error)
            Self.sharedGestureInfoStore?.updateDebugInfo("エラー: \(error.localizedDescription)")
        }
    }

    /// パフォーマンス統計を更新
    fileprivate func updatePerformanceStats(_ detectedGestures: [DetectedGesture]) {
        let stats = unifiedDetector.searchStats
        Self.sharedGestureInfoStore?.updatePerformanceStats(stats)

        // パフォーマンス統計を出力(デバッグ用)
        if detectedGestures.count > 0 {
            HandGestureLogger.logPerformance(
                "📊 検出統計: 検索数=\(stats.searchCount), チェック数=\(stats.gesturesChecked), 平均時間=\(String(format: "%.3f", stats.averageSearchTime * 1000))ms"
            )
        }
    }
}

// MARK: - Hand State Updates

extension HandGestureTrackingSystem {

    /// 個別の手の状態を更新
    fileprivate func updateHandStates(from handEntities: [Entity]) {
        var allFingerDistances:
            [(finger1: FingerType, finger2: FingerType, distance: Float, hand: HandKind)] = []

        for entity in handEntities {
            guard let handComponent = entity.components[HandTrackingComponent.self] else {
                continue
            }

            let handKind: HandKind = (handComponent.chirality == .left) ? .left : .right

            // SingleHandGestureDataを作成
            let gestureData = SingleHandGestureData(
                handTrackingComponent: handComponent,
                handKind: handKind
            )

            // 指の状態を更新
            updateFingerStates(
                handComponent: handComponent, gestureData: gestureData, handKind: handKind)

            // 手のひらの向きを更新
            let palmDirection = handComponent.getPalmDirection()
            Self.sharedGestureInfoStore?.updatePalmDirection(
                direction: palmDirection, forHand: handKind)

            // 指同士の距離を計算
            let distances = calculateFingerDistances(
                handComponent: handComponent, handKind: handKind)
            allFingerDistances.append(contentsOf: distances)
        }

        // 指同士の距離情報を更新
        Self.sharedGestureInfoStore?.updateFingerDistances(allFingerDistances)
    }

    /// 指の状態を更新
    fileprivate func updateFingerStates(
        handComponent: HandTrackingComponent, gestureData: SingleHandGestureData, handKind: HandKind
    ) {
        let fingers: [FingerType] = [.thumb, .index, .middle, .ring, .little]

        for finger in fingers {
            // 伸展状態
            let isExtended = handComponent.isFingerStraight(finger, tolerance: Float.pi / 4)
            Self.sharedGestureInfoStore?.updateFingerState(
                finger: finger, isExtended: isExtended, forHand: handKind)

            // 曲がり具合レベル
            let bendLevel = gestureData.getFingerBendLevel(finger)
            Self.sharedGestureInfoStore?.updateFingerBendLevel(
                finger: finger, level: bendLevel, forHand: handKind)

            // 指の向き
            let direction = gestureData.fingerDirection(for: finger)
            Self.sharedGestureInfoStore?.updateFingerDirection(
                finger: finger, direction: direction, forHand: handKind)
        }
    }

    /// 指同士の距離を計算
    fileprivate func calculateFingerDistances(
        handComponent: HandTrackingComponent, handKind: HandKind
    ) -> [(finger1: FingerType, finger2: FingerType, distance: Float, hand: HandKind)] {
        var distances:
            [(finger1: FingerType, finger2: FingerType, distance: Float, hand: HandKind)] = []
        let fingers: [FingerType] = [.thumb, .index, .middle, .ring, .little]

        // 親指と他の指の距離
        for otherFinger in fingers where otherFinger != .thumb {
            if let distance = calculateFingerTipDistance(
                handComponent: handComponent, finger1: .thumb, finger2: otherFinger)
            {
                distances.append(
                    (finger1: .thumb, finger2: otherFinger, distance: distance, hand: handKind))
            }
        }

        // 隣接する指の距離
        let adjacentPairs: [(FingerType, FingerType)] = [
            (.index, .middle),
            (.middle, .ring),
            (.ring, .little),
        ]

        for pair in adjacentPairs {
            if let distance = calculateFingerTipDistance(
                handComponent: handComponent, finger1: pair.0, finger2: pair.1)
            {
                distances.append(
                    (finger1: pair.0, finger2: pair.1, distance: distance, hand: handKind))
            }
        }

        return distances
    }

    /// 2つの指先間の距離を計算
    fileprivate func calculateFingerTipDistance(
        handComponent: HandTrackingComponent, finger1: FingerType, finger2: FingerType
    ) -> Float? {
        let tipJoint1: HandSkeleton.JointName
        let tipJoint2: HandSkeleton.JointName

        switch finger1 {
        case .thumb: tipJoint1 = .thumbTip
        case .index: tipJoint1 = .indexFingerTip
        case .middle: tipJoint1 = .middleFingerTip
        case .ring: tipJoint1 = .ringFingerTip
        case .little: tipJoint1 = .littleFingerTip
        }

        switch finger2 {
        case .thumb: tipJoint2 = .thumbTip
        case .index: tipJoint2 = .indexFingerTip
        case .middle: tipJoint2 = .middleFingerTip
        case .ring: tipJoint2 = .ringFingerTip
        case .little: tipJoint2 = .littleFingerTip
        }

        guard let tip1Entity = handComponent.fingers[tipJoint1],
            let tip2Entity = handComponent.fingers[tipJoint2]
        else {
            return nil
        }

        let tip1Pos = tip1Entity.position(relativeTo: nil)
        let tip2Pos = tip2Entity.position(relativeTo: nil)

        return simd_distance(tip1Pos, tip2Pos)
    }
}

// MARK: - Visual Updates

extension HandGestureTrackingSystem {

    /// 手の色を更新
    fileprivate func updateHandColors(detectedGestures: [DetectedGesture], handEntities: [Entity]) {
        // まずデフォルト色に戻す
        resetHandColors(handEntities: handEntities)

        // 検出されたジェスチャーに基づいて色を更新
        for detected in detectedGestures {
            if detected.gesture.gestureType == .singleHand,
                let hand = detected.metadata["detectedHand"] as? String
            {
                updateSingleHandColor(hand: hand, handEntities: handEntities)
            } else if detected.gesture.gestureType == .twoHand {
                updateBothHandsColor(handEntities: handEntities)
            }
        }
    }

    /// デフォルト色にリセット
    fileprivate func resetHandColors(handEntities: [Entity]) {
        for entity in handEntities {
            guard let handComponent = entity.components[HandTrackingComponent.self] else {
                continue
            }
            let defaultColor = getDefaultColor(for: handComponent.chirality)
            updateHandColor(handComponent: handComponent, color: defaultColor)
        }
    }

    /// 片手の色を更新
    fileprivate func updateSingleHandColor(hand: String, handEntities: [Entity]) {
        for entity in handEntities {
            guard let handComponent = entity.components[HandTrackingComponent.self] else {
                continue
            }
            let isTargetHand =
                (hand == "left" && handComponent.chirality == .left)
                || (hand == "right" && handComponent.chirality == .right)
            if isTargetHand {
                updateHandColor(handComponent: handComponent, color: .green)
            }
        }
    }

    /// 両手の色を更新
    fileprivate func updateBothHandsColor(handEntities: [Entity]) {
        for entity in handEntities {
            guard let handComponent = entity.components[HandTrackingComponent.self] else {
                continue
            }
            updateHandColor(handComponent: handComponent, color: .green)
        }
    }

    /// 手の色を更新
    fileprivate func updateHandColor(handComponent: HandTrackingComponent, color: Color) {
        for entity in handComponent.fingers.values {
            var material = SimpleMaterial()
            material.color = .init(tint: UIColor(color))

            if var modelComponent = entity.components[ModelComponent.self] {
                modelComponent.materials = [material]
                entity.components[ModelComponent.self] = modelComponent
            }
        }
    }

    /// デフォルト色を取得
    fileprivate func getDefaultColor(for chirality: HandAnchor.Chirality) -> Color {
        return chirality == .left ? .orange : .cyan
    }

    /// 手話ジェスチャーの処理
    fileprivate func processSignLanguageGestures(
        _ detectedGestures: [DetectedGesture], gestureInfoStore: GestureInfoStore
    ) {
        // 1秒間隔のチェック
        if let lastDetectionTime = gestureInfoStore.lastSignLanguageDetectionTime {
            let timeSinceLastDetection = Date().timeIntervalSince(lastDetectionTime)
            if timeSinceLastDetection < 1.0 {
                // 1秒経過していない場合は処理をスキップ
                return
            }
        }

        // 手話ジェスチャーを検出した場合、meaningを追加(シリアルジェスチャーを除く)
        for detected in detectedGestures {
            if let signLanguageGesture = detected.gesture as? SignLanguageProtocol,
                !(detected.gesture is SerialGestureProtocol)
            {
                gestureInfoStore.appendSignLanguageMeaning(signLanguageGesture.meaning)
                break  // 最初の1つだけ処理
            }
        }
    }

    /// シリアルジェスチャーの処理
    fileprivate func processSerialGestures(handEntities: [Entity]) {
        guard let gestureInfoStore = Self.sharedGestureInfoStore else { return }

        // 手話モードが有効でない場合はスキップ
        guard gestureInfoStore.isHandLanguageDetectionEnabled else {
            if serialGestureTracker.isTracking {
                serialGestureTracker.reset()
                gestureInfoStore.clearSerialGestureProgress()
            }
            return
        }

        // タイムアウトチェック
        if serialGestureTracker.isTimedOut() {
            HandGestureLogger.logDebug("🔴 シリアルジェスチャーがタイムアウトしました")
            serialGestureTracker.reset()
            gestureInfoStore.clearSerialGestureProgress()
            return
        }

        // 現在追跡中のジェスチャーがある場合
        if let currentGesture = serialGestureTracker.currentGesture {
            // 現在のステップのジェスチャーを検出
            let result = unifiedDetector.detectSerialGesture(
                from: handEntities,
                serialGesture: currentGesture,
                currentIndex: serialGestureTracker.currentIndex
            )

            // 進行状況を更新(検出後に更新)
            gestureInfoStore.updateSerialGestureProgress(
                name: currentGesture.gestureName,
                current: serialGestureTracker.currentIndex,
                total: currentGesture.gestures.count,
                descriptions: currentGesture.stepDescriptions,
                timeRemaining: serialGestureTracker.timeRemaining()
            )

            // 結果を処理
            let updatedResult = serialGestureTracker.update(with: result)

            switch updatedResult {
            case .completed(let gesture):
                HandGestureLogger.logDebug("✅ シリアルジェスチャー完了: \(gesture.gestureName)")
                gestureInfoStore.appendSignLanguageMeaning(gesture.meaning)
                gestureInfoStore.clearSerialGestureProgress()

            case .progress(let current, let total, _):
                HandGestureLogger.logDebug("⏳ シリアルジェスチャー進行中: \(current)/\(total)")

            case .timeout:
                HandGestureLogger.logDebug("⏰ シリアルジェスチャーがタイムアウト")
                gestureInfoStore.clearSerialGestureProgress()

            case .notMatched:
                // マッチしない場合は継続して待機
                break
            }
        } else {
            // 新しいシリアルジェスチャーの開始をチェック
            for serialGesture in serialGestures {
                // クールダウン中はスキップ
                if serialGestureTracker.shouldSkipGesture(serialGesture) {
                    continue
                }

                // 最初のジェスチャーがマッチするかチェック
                let result = unifiedDetector.detectSerialGesture(
                    from: handEntities,
                    serialGesture: serialGesture,
                    currentIndex: 0
                )

                if case .progress = result {
                    // 最初のステップが本当に検出されたか確認
                    HandGestureLogger.logDebug("🟢 新しいシリアルジェスチャー開始: \(serialGesture.gestureName)")
                    serialGestureTracker.startTracking(serialGesture)
                    let _ = serialGestureTracker.update(with: result)
                    break  // 最初にマッチしたものを使用
                }
            }
        }
    }
}
