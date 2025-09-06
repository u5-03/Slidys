//
//  SingleHandGestureProtocol.swift
//  HandGestureKit
//
//  Created by Yugo Sugiyama on 2025/07/30.
//

import Foundation

/// 片手ジェスチャーの条件を定義するプロトコル
/// 各ジェスチャーはこのプロトコルを実装して、必要な条件だけを定義する
public protocol SingleHandGestureProtocol: BaseGestureProtocol {

    // MARK: - ジェスチャーマッチング

    /// 指定されたSingleHandGestureDataがこのジェスチャーの条件を満たすかを判定
    /// - Parameter gestureData: 判定対象の手のデータ
    /// - Returns: 条件を満たす場合true
    func matches(_ gestureData: SingleHandGestureData) -> Bool

    // MARK: - 指の状態判定関数

    /// 指定した指群が伸びている必要があるかを判定
    /// - Parameter fingers: 判定対象の指の配列
    /// - Returns: 指定した指群が伸びている必要がある場合true
    func requiresFingersStraight(_ fingers: [FingerType]) -> Bool

    /// 指定した指群が曲がっている必要があるかを判定
    /// - Parameter fingers: 判定対象の指の配列
    /// - Returns: 指定した指群が曲がっている必要がある場合true
    func requiresFingersBent(_ fingers: [FingerType]) -> Bool

    /// 指定した指が特定の方向を向いている必要があるかを判定
    /// - Parameters:
    ///   - finger: 判定対象の指
    ///   - direction: 期待する方向
    /// - Returns: 指定した指が特定の方向を向いている必要がある場合true
    func requiresFingerPointing(_ finger: FingerType, direction: GestureDetectionDirection) -> Bool

    // MARK: - 手のひらの方向判定関数

    /// 手のひらが特定の方向を向いている必要があるかを判定
    /// - Parameter direction: 期待する方向
    /// - Returns: 手のひらが特定の方向を向いている必要がある場合true
    func requiresPalmFacing(_ direction: GestureDetectionDirection) -> Bool

    // MARK: - 腕の方向判定関数

    /// 腕が特定の方向に伸びている必要があるかを判定
    /// - Parameter direction: 期待する方向
    /// - Returns: 腕が特定の方向に伸びている必要がある場合true
    func requiresArmExtendedInDirection(_ direction: GestureDetectionDirection) -> Bool

    // MARK: - 複合的な指の条件(便利プロパティ)

    /// すべての指が曲がっている必要があるか(握り拳状態)
    var requiresAllFingersBent: Bool { get }

    /// 人差し指だけが伸びている必要があるか
    var requiresOnlyIndexFingerStraight: Bool { get }

    /// 人差し指と中指だけが伸びている必要があるか(ピースサインなど)
    var requiresOnlyIndexAndMiddleStraight: Bool { get }

    /// 親指だけが伸びている必要があるか
    var requiresOnlyThumbStraight: Bool { get }

    /// 小指だけが伸びている必要があるか
    var requiresOnlyLittleFingerStraight: Bool { get }

    // MARK: - 手首の状態条件

    /// 手首が外側(甲側)に曲がっている必要があるか
    var requiresWristBentOutward: Bool { get }

    /// 手首が内側(手のひら側)に曲がっている必要があるか
    var requiresWristBentInward: Bool { get }

    /// 手首がまっすぐである必要があるか
    var requiresWristStraight: Bool { get }

    // MARK: - 腕の状態条件

    /// 腕が伸びている必要があるか
    var requiresArmExtended: Bool { get }
}

/// デフォルト実装：すべての条件をfalseに設定
/// 各ジェスチャーは必要な条件だけをオーバーライドする
extension SingleHandGestureProtocol {

    // MARK: - デフォルト識別情報

    /// デフォルトの優先度(低優先度)
    public var priority: Int { 1000 }


    /// デフォルトのジェスチャータイプ
    public var gestureType: GestureType { .singleHand }

    // MARK: - デフォルトマッチング実装

    /// デフォルトのマッチング実装：すべての条件をチェック
    public func matches(_ gestureData: SingleHandGestureData) -> Bool {
        // 早期リターン：基本的な条件チェック

        // 1. 複合的な指の条件チェック
        if requiresAllFingersBent && !areAllFingersBent(gestureData) {
            return false
        }

        if requiresOnlyIndexFingerStraight && !isOnlyIndexFingerStraight(gestureData) {
            return false
        }

        if requiresOnlyIndexAndMiddleStraight && !isOnlyIndexAndMiddleStraight(gestureData) {
            return false
        }

        if requiresOnlyThumbStraight && !isOnlyThumbStraight(gestureData) {
            return false
        }

        if requiresOnlyLittleFingerStraight && !isOnlyLittleFingerStraight(gestureData) {
            return false
        }

        // 2. 手首の状態チェック
        if requiresWristBentOutward && !gestureData.isWristBentOutward {
            return false
        }

        if requiresWristBentInward && !gestureData.isWristBentInward {
            return false
        }

        if requiresWristStraight && !gestureData.isWristStraight {
            return false
        }

        // 3. 腕の状態チェック
        if requiresArmExtended && !gestureData.armExtended {
            return false
        }

        // 4. 個別の指の状態チェック(FingerType全てをチェック)
        for finger in FingerType.allCases {
            // 指の伸び状態チェック
            if requiresFingersStraight([finger]) && !gestureData.isFingerStraight(finger) {
                return false
            }

            if requiresFingersBent([finger]) && !gestureData.isFingerBent(finger) {
                return false
            }

            // 指の方向チェック(全方向をテスト)
            for direction in GestureDetectionDirection.allCases {
                if requiresFingerPointing(finger, direction: direction)
                    && !gestureData.isFingerPointing(finger, direction: direction)
                {
                    return false
                }
            }
        }

        // 5. 手のひらの方向チェック
        for direction in GestureDetectionDirection.allCases {
            if requiresPalmFacing(direction) && !gestureData.isPalmFacing(direction) {
                return false
            }
        }

        // 6. 腕の方向チェック
        for direction in GestureDetectionDirection.allCases {
            if requiresArmExtendedInDirection(direction)
                && !gestureData.isArmExtendedInDirection(direction)
            {
                return false
            }
        }

        return true
    }

    // MARK: - 指の状態判定関数(デフォルト実装)

    /// 指定した指群が伸びている必要があるか(デフォルト：不要)
    public func requiresFingersStraight(_ fingers: [FingerType]) -> Bool {
        return false
    }

    /// 指定した指群が曲がっている必要があるか(デフォルト：不要)
    public func requiresFingersBent(_ fingers: [FingerType]) -> Bool {
        return false
    }

    /// 指定した指が特定の方向を向いている必要があるか(デフォルト：不要)
    public func requiresFingerPointing(_ finger: FingerType, direction: GestureDetectionDirection)
        -> Bool
    {
        return false
    }

    // MARK: - 手のひらの方向判定関数(デフォルト実装)

    /// 手のひらが特定の方向を向いている必要があるか(デフォルト：不要)
    public func requiresPalmFacing(_ direction: GestureDetectionDirection) -> Bool {
        return false
    }

    // MARK: - 腕の方向判定関数(デフォルト実装)

    /// 腕が特定の方向に伸びている必要があるか(デフォルト：不要)
    public func requiresArmExtendedInDirection(_ direction: GestureDetectionDirection) -> Bool {
        return false
    }

    // MARK: - 複合的な指の条件(デフォルト値)

    public var requiresAllFingersBent: Bool { false }
    public var requiresOnlyIndexFingerStraight: Bool { false }
    public var requiresOnlyIndexAndMiddleStraight: Bool { false }
    public var requiresOnlyThumbStraight: Bool { false }
    public var requiresOnlyLittleFingerStraight: Bool { false }

    // MARK: - 手首の状態条件(デフォルト値)

    public var requiresWristBentOutward: Bool { false }
    public var requiresWristBentInward: Bool { false }
    public var requiresWristStraight: Bool { false }

    // MARK: - 腕の状態条件(デフォルト値)

    public var requiresArmExtended: Bool { false }

    // MARK: - ヘルパーメソッド(デフォルト実装)

    /// すべての指が曲がっているかを判定
    private func areAllFingersBent(_ gestureData: SingleHandGestureData) -> Bool {
        return FingerType.allCases.allSatisfy { gestureData.isFingerBent($0) }
    }

    /// 人差し指だけが伸びているかを判定
    private func isOnlyIndexFingerStraight(_ gestureData: SingleHandGestureData) -> Bool {
        return gestureData.isFingerStraight(.index) && gestureData.isFingerBent(.thumb)
            && gestureData.isFingerBent(.middle) && gestureData.isFingerBent(.ring)
            && gestureData.isFingerBent(.little)
    }

    /// 人差し指と中指だけが伸びているかを判定
    private func isOnlyIndexAndMiddleStraight(_ gestureData: SingleHandGestureData) -> Bool {
        return gestureData.isFingerStraight(.index) && gestureData.isFingerStraight(.middle)
            && gestureData.isFingerBent(.thumb) && gestureData.isFingerBent(.ring)
            && gestureData.isFingerBent(.little)
    }

    /// 親指だけが伸びているかを判定
    private func isOnlyThumbStraight(_ gestureData: SingleHandGestureData) -> Bool {
        return gestureData.isFingerStraight(.thumb) && gestureData.isFingerBent(.index)
            && gestureData.isFingerBent(.middle) && gestureData.isFingerBent(.ring)
            && gestureData.isFingerBent(.little)
    }

    /// 小指だけが伸びているかを判定
    private func isOnlyLittleFingerStraight(_ gestureData: SingleHandGestureData) -> Bool {
        return gestureData.isFingerStraight(.little) && gestureData.isFingerBent(.thumb)
            && gestureData.isFingerBent(.index) && gestureData.isFingerBent(.middle)
            && gestureData.isFingerBent(.ring)
    }
}

// MARK: - Advanced Protocol Extensions

extension SingleHandGestureProtocol {

    // MARK: - Performance Optimized Matching

    /// 複数条件の高速検証(早期リターン最適化)
    /// - Parameter gestureData: 検証対象のジェスチャーデータ
    /// - Returns: 全条件を満たす場合true
    public func matchesWithOptimization(_ gestureData: SingleHandGestureData) -> Bool {
        // 1. Most selective conditions first (finger configuration)
        if requiresOnlyIndexAndMiddleStraight {
            guard
                GestureValidation.validateOnlyTargetFingersStraight(
                    gestureData,
                    targetFingers: [.index, .middle]
                )
            else { return false }
        }

        if requiresOnlyIndexFingerStraight {
            guard
                GestureValidation.validateOnlyTargetFingersStraight(
                    gestureData,
                    targetFingers: [.index]
                )
            else { return false }
        }

        if requiresOnlyThumbStraight {
            guard
                GestureValidation.validateOnlyTargetFingersStraight(
                    gestureData,
                    targetFingers: [.thumb]
                )
            else { return false }
        }

        if requiresOnlyLittleFingerStraight {
            guard
                GestureValidation.validateOnlyTargetFingersStraight(
                    gestureData,
                    targetFingers: [.little]
                )
            else { return false }
        }

        if requiresAllFingersBent {
            guard GestureValidation.validateFistGesture(gestureData) else { return false }
        }

        // 2. Direction checks (moderate selectivity)
        for direction in GestureDetectionDirection.allCases {
            if requiresPalmFacing(direction) {
                guard gestureData.isPalmFacing(direction) else { return false }
            }
        }

        // 3. Individual finger direction checks (potentially expensive)
        for finger in FingerType.allCases {
            for direction in GestureDetectionDirection.allCases {
                if requiresFingerPointing(finger, direction: direction) {
                    guard gestureData.isFingerPointing(finger, direction: direction) else {
                        return false
                    }
                }
            }
        }

        // 4. Wrist and arm checks (least selective, checked last)
        if requiresWristStraight && !gestureData.isWristStraight { return false }
        if requiresWristBentInward && !gestureData.isWristBentInward { return false }
        if requiresWristBentOutward && !gestureData.isWristBentOutward { return false }
        if requiresArmExtended && !gestureData.armExtended { return false }

        return true
    }

    // MARK: - Gesture Confidence Scoring

    /// ジェスチャーの一致度スコアを計算(0.0-1.0)
    /// - Parameter gestureData: 評価対象のジェスチャーデータ
    /// - Returns: 一致度スコア(1.0が完全一致)
    public func confidenceScore(for gestureData: SingleHandGestureData) -> Double {
        var totalConditions = 0
        var matchedConditions = 0

        // Finger configuration checks
        if requiresOnlyIndexAndMiddleStraight {
            totalConditions += 1
            if GestureValidation.validateOnlyTargetFingersStraight(
                gestureData,
                targetFingers: [.index, .middle]
            ) {
                matchedConditions += 1
            }
        }

        if requiresOnlyIndexFingerStraight {
            totalConditions += 1
            if GestureValidation.validateOnlyTargetFingersStraight(
                gestureData,
                targetFingers: [.index]
            ) {
                matchedConditions += 1
            }
        }

        if requiresOnlyThumbStraight {
            totalConditions += 1
            if GestureValidation.validateOnlyTargetFingersStraight(
                gestureData,
                targetFingers: [.thumb]
            ) {
                matchedConditions += 1
            }
        }

        if requiresAllFingersBent {
            totalConditions += 1
            if GestureValidation.validateFistGesture(gestureData) {
                matchedConditions += 1
            }
        }

        // Palm direction checks
        for direction in GestureDetectionDirection.allCases {
            if requiresPalmFacing(direction) {
                totalConditions += 1
                if gestureData.isPalmFacing(direction) {
                    matchedConditions += 1
                }
            }
        }

        // Finger direction checks
        for finger in FingerType.allCases {
            for direction in GestureDetectionDirection.allCases {
                if requiresFingerPointing(finger, direction: direction) {
                    totalConditions += 1
                    if gestureData.isFingerPointing(finger, direction: direction) {
                        matchedConditions += 1
                    }
                }
            }
        }

        return totalConditions > 0 ? Double(matchedConditions) / Double(totalConditions) : 0.0
    }

    // MARK: - Debugging Support

    /// ジェスチャー条件の詳細情報を取得(デバッグ用)
    public var conditionsDescription: String {
        var conditions: [String] = []

        if requiresOnlyIndexAndMiddleStraight {
            conditions.append("人差し指と中指のみ伸ばす")
        }
        if requiresOnlyIndexFingerStraight {
            conditions.append("人差し指のみ伸ばす")
        }
        if requiresOnlyThumbStraight {
            conditions.append("親指のみ伸ばす")
        }
        if requiresAllFingersBent {
            conditions.append("全ての指を曲げる")
        }

        for direction in GestureDetectionDirection.allCases {
            if requiresPalmFacing(direction) {
                conditions.append("手のひらを\(direction)に向ける")
            }
        }

        return conditions.isEmpty ? "条件なし" : conditions.joined(separator: ", ")
    }

    // MARK: - Gesture Comparison

    /// 他のジェスチャーとの類似度を計算
    /// - Parameters:
    ///   - other: 比較対象のジェスチャー
    ///   - gestureData: テスト用のジェスチャーデータ
    /// - Returns: 類似度スコア(0.0-1.0)
    public func similarity(
        to other: SingleHandGestureProtocol, using gestureData: SingleHandGestureData
    ) -> Double {
        let thisScore = self.confidenceScore(for: gestureData)
        let otherScore = other.confidenceScore(for: gestureData)

        // Calculate similarity based on score difference
        let scoreDifference = abs(thisScore - otherScore)
        return 1.0 - scoreDifference
    }
}

// MARK: - Gesture Collection Extensions

extension Collection where Element == SingleHandGestureProtocol {

    /// 指定されたジェスチャーデータに対する全ジェスチャーの信頼度を計算
    /// - Parameter gestureData: 評価対象のジェスチャーデータ
    /// - Returns: ジェスチャー名と信頼度のタプル配列(信頼度降順)
    public func confidenceScores(for gestureData: SingleHandGestureData) -> [(String, Double)] {
        return self.map { gesture in
            (gesture.gestureName, gesture.confidenceScore(for: gestureData))
        }.sorted { $0.1 > $1.1 }
    }

    /// 最も信頼度の高いジェスチャーを取得
    /// - Parameter gestureData: 評価対象のジェスチャーデータ
    /// - Returns: 最高信頼度のジェスチャー(見つからない場合はnil)
    public func mostConfidentGesture(for gestureData: SingleHandGestureData)
        -> SingleHandGestureProtocol?
    {
        return self.max { gesture1, gesture2 in
            gesture1.confidenceScore(for: gestureData) < gesture2.confidenceScore(for: gestureData)
        }
    }
}
