import Foundation
import HandGestureKit
import Observation
import RealityKit

/// ジェスチャー検知結果を保存・共有するためのデータストア
@Observable
public final class GestureInfoStore: @unchecked Sendable {

    // MARK: - 検出結果データ

    /// 左手の検出されたジェスチャータイプ
    public var leftHandGesture: HandGestureType?

    /// 右手の検出されたジェスチャータイプ
    public var rightHandGesture: HandGestureType?

    /// 両手のジェスチャー(新システム)
    public var detectedTwoHandGestures: [String] = []

    /// 両手の手のひら間の距離
    public var twoHandPalmDistance: Float = 0

    /// 両手が向かい合っているか
    public var twoHandsAreFacingEachOther = false

    /// 統合検出システムの結果
    public var detectedGestures: [DetectedGesture] = []

    /// パフォーマンス統計
    public var performanceStats: SearchStats?

    /// 左手の手のひらの向き
    public var leftPalmDirection: PalmDirection = .unknown

    /// 右手の手のひらの向き
    public var rightPalmDirection: PalmDirection = .unknown

    /// 左手の指の状態(伸びている/曲がっている)
    public var leftFingerStates: [FingerType: Bool] = [:]

    /// 右手の指の状態(伸びている/曲がっている)
    public var rightFingerStates: [FingerType: Bool] = [:]

    /// 左手の指の曲がり具合レベル
    public var leftFingerBendLevels: [FingerType: SingleHandGestureData.FingerBendLevel] = [:]

    /// 右手の指の曲がり具合レベル
    public var rightFingerBendLevels: [FingerType: SingleHandGestureData.FingerBendLevel] = [:]

    /// 左手の指の向き
    public var leftFingerDirections: [FingerType: GestureDetectionDirection] = [:]

    /// 右手の指の向き
    public var rightFingerDirections: [FingerType: GestureDetectionDirection] = [:]

    /// 指同士の距離情報(デバッグ用)
    public var fingerDistances:
        [(finger1: FingerType, finger2: FingerType, distance: Float, hand: HandKind)] = []

    /// 左手の検出信頼度
    public var leftHandConfidence: Float = 0

    /// 右手の検出信頼度
    public var rightHandConfidence: Float = 0

    /// デバッグ情報(任意のテキスト)
    public var debugInfo = ""

    /// 最後の更新タイムスタンプ
    public var lastUpdateTimestamp = Date()

    /// 手のエンティティを表示するかどうか
    public var showHandEntities = true

    /// 手話検知を有効にするかどうか
    public var isHandLanguageDetectionEnabled = false

    /// 有効なジェスチャーのセット(ジェスチャーIDで管理)
    public var enabledGestureIds: Set<String> = AvailableGestures.defaultEnabledGestureIds

    /// 検出した手話の意味を蓄積するテキスト
    public var detectedSignLanguageText = ""

    /// 最後に手話を検出した時刻
    public var lastSignLanguageDetectionTime: Date?

    // MARK: - シリアルジェスチャー追跡用プロパティ

    /// シリアルジェスチャーが進行中かどうか
    public var serialGestureInProgress = false

    /// 現在のシリアルジェスチャーの名前
    public var serialGestureName = ""

    /// 現在のステップ(0ベース)
    public var serialGestureCurrentStep = 0

    /// 総ステップ数
    public var serialGestureTotalSteps = 0

    /// 各ステップの説明
    public var serialGestureStepDescriptions: [String] = []

    /// 残り時間(秒)
    public var serialGestureTimeRemaining: TimeInterval = 0

    public init() {
        // デフォルトで有効なジェスチャーを設定
        self.enabledGestureIds = AvailableGestures.defaultEnabledGestureIds
    }

    // MARK: - Public Methods

    /// 左手のジェスチャー情報を更新
    public func updateLeftHandGesture(_ gesture: HandGestureType?) {
        leftHandGesture = gesture
        lastUpdateTimestamp = Date()
    }

    /// 右手のジェスチャー情報を更新
    public func updateRightHandGesture(_ gesture: HandGestureType?) {
        rightHandGesture = gesture
        lastUpdateTimestamp = Date()
    }

    /// 手のひらの向き情報を更新
    public func updatePalmDirection(direction: PalmDirection, forHand chirality: HandKind) {
        switch chirality {
        case .left:
            leftPalmDirection = direction
        case .right:
            rightPalmDirection = direction
        }
        lastUpdateTimestamp = Date()
    }

    /// 指の状態情報を更新
    public func updateFingerState(finger: FingerType, isExtended: Bool, forHand chirality: HandKind)
    {
        switch chirality {
        case .left:
            leftFingerStates[finger] = isExtended
        case .right:
            rightFingerStates[finger] = isExtended
        }
        lastUpdateTimestamp = Date()
    }

    /// 指の曲がり具合レベルを更新
    public func updateFingerBendLevel(
        finger: FingerType, level: SingleHandGestureData.FingerBendLevel,
        forHand chirality: HandKind
    ) {
        switch chirality {
        case .left:
            leftFingerBendLevels[finger] = level
        case .right:
            rightFingerBendLevels[finger] = level
        }
        lastUpdateTimestamp = Date()
    }

    /// 指の向きを更新
    public func updateFingerDirection(
        finger: FingerType, direction: GestureDetectionDirection, forHand chirality: HandKind
    ) {
        switch chirality {
        case .left:
            leftFingerDirections[finger] = direction
        case .right:
            rightFingerDirections[finger] = direction
        }
        lastUpdateTimestamp = Date()
    }

    /// 指同士の距離情報を更新
    public func updateFingerDistances(
        _ distances: [(finger1: FingerType, finger2: FingerType, distance: Float, hand: HandKind)]
    ) {
        self.fingerDistances = distances
        lastUpdateTimestamp = Date()
    }

    /// 手の検出信頼度を更新
    public func updateHandConfidence(confidence: Float, forHand chirality: HandKind) {
        switch chirality {
        case .left:
            leftHandConfidence = confidence
        case .right:
            rightHandConfidence = confidence
        }
        lastUpdateTimestamp = Date()
    }

    /// デバッグ情報を更新
    public func updateDebugInfo(_ info: String) {
        debugInfo = info
        lastUpdateTimestamp = Date()
    }

    /// 両手ジェスチャー情報を更新
    public func updateTwoHandGesturesInfo(
        detectedGestures: [String], palmDistance: Float, areFacingEachOther: Bool
    ) {
        self.detectedTwoHandGestures = detectedGestures
        self.twoHandPalmDistance = palmDistance
        self.twoHandsAreFacingEachOther = areFacingEachOther
        lastUpdateTimestamp = Date()
    }

    /// 統合検出結果を更新
    public func updateDetectedGestures(_ gestures: [DetectedGesture]) {
        self.detectedGestures = gestures

        // 両手ジェスチャーの情報も更新
        detectedTwoHandGestures =
            gestures
            .filter { $0.gesture.gestureType == .twoHand }
            .map { $0.gesture.gestureName }

        lastUpdateTimestamp = Date()
    }

    /// パフォーマンス統計を更新
    public func updatePerformanceStats(_ stats: SearchStats) {
        self.performanceStats = stats
        lastUpdateTimestamp = Date()
    }

    /// すべての状態をリセット
    public func resetAll() {
        leftHandGesture = nil
        rightHandGesture = nil
        detectedTwoHandGestures = []
        twoHandPalmDistance = 0.0
        twoHandsAreFacingEachOther = false
        leftPalmDirection = .unknown
        rightPalmDirection = .unknown
        leftFingerStates = [:]
        rightFingerStates = [:]
        leftFingerBendLevels = [:]
        rightFingerBendLevels = [:]
        leftFingerDirections = [:]
        rightFingerDirections = [:]
        fingerDistances = []
        leftHandConfidence = 0.0
        rightHandConfidence = 0.0
        debugInfo = ""
        detectedGestures = []
        performanceStats = nil
        detectedSignLanguageText = ""
        lastSignLanguageDetectionTime = nil
        lastUpdateTimestamp = Date()
    }

    /// 手話テキストをクリア
    public func clearSignLanguageText() {
        detectedSignLanguageText = ""
        lastUpdateTimestamp = Date()
    }

    // MARK: - シリアルジェスチャー追跡メソッド

    /// シリアルジェスチャーの進行状況を更新
    public func updateSerialGestureProgress(
        name: String,
        current: Int,
        total: Int,
        descriptions: [String],
        timeRemaining: TimeInterval
    ) {
        HandGestureLogger.logDebug(
            "📊 進行状況更新: \(name) - ステップ \(current)/\(total), 残り時間: \(timeRemaining)秒")
        serialGestureInProgress = true
        serialGestureName = name
        serialGestureCurrentStep = current
        serialGestureTotalSteps = total
        serialGestureStepDescriptions = descriptions
        serialGestureTimeRemaining = timeRemaining
        lastUpdateTimestamp = Date()
    }

    /// シリアルジェスチャーの進行状況をクリア
    public func clearSerialGestureProgress() {
        HandGestureLogger.logDebug("🧹 進行状況をクリア")
        serialGestureInProgress = false
        serialGestureName = ""
        serialGestureCurrentStep = 0
        serialGestureTotalSteps = 0
        serialGestureStepDescriptions = []
        serialGestureTimeRemaining = 0
        lastUpdateTimestamp = Date()
    }

    /// 手話の意味を追加
    public func appendSignLanguageMeaning(_ meaning: String) {
        HandGestureLogger.logDebug(
            "📝 手話テキスト追加: '\(meaning)' → 現在のテキスト: '\(detectedSignLanguageText + meaning)'")
        detectedSignLanguageText += meaning
        lastSignLanguageDetectionTime = Date()
        lastUpdateTimestamp = Date()
    }
}
