//
//  SingleHandGestureData.swift
//  HandGesturePackage
//
//  Created by Yugo Sugiyama on 2025/07/16.
//

import Foundation
import RealityKit
import ARKit
 
public enum GestureDetectionDirection: CaseIterable {
    case top
    case bottom
    case forward
    case backward
    case right
    case left
}

public enum HandKind {
    case right
    case left
}

public struct SingleHandGestureData {
    public let handTrackingComponent: HandTrackingComponent
    public let handKind: HandKind

    // 閾値設定 - ジェスチャー判定の精度を調整するためのパラメータ
    public let angleToleranceRadians: Float    // 角度判定の許容範囲（指の曲がり、腕の伸展など）
    public let distanceThreshold: Float        // 距離判定の閾値（指先接触判定など）
    public let directionToleranceRadians: Float // 方向判定の許容角度（指差し、手のひら向きなど）

    // パフォーマンス最適化のための事前計算値 - 初期化時に計算して再利用
    private let palmNormal: SIMD3<Float>       // 手のひらの法線ベクトル
    private let forearmDirection: SIMD3<Float> // 前腕の方向ベクトル
    private let wristPosition: SIMD3<Float>    // 手首の位置
    private let isArmExtended: Bool            // 腕の伸展状態（事前判定済み）

        /// SingleHandGestureDataの初期化メソッド
    /// - Parameters:
    ///   - handTrackingComponent: 手のトラッキング情報を含むコンポーネント
    ///   - handKind: 左手か右手かを示す識別子
    ///   - angleToleranceRadians: 角度判定の許容範囲（デフォルト30度）- 指の曲がりや腕の伸展判定に使用
    ///   - distanceThreshold: 距離判定の閾値（デフォルト2cm）- 指先の接触判定などに使用
    ///   - directionToleranceRadians: 方向判定の許容角度（デフォルト45度）- 指差しや手のひらの向き判定に使用
    public init(
        handTrackingComponent: HandTrackingComponent,
        handKind: HandKind,
        angleToleranceRadians: Float = .pi / 6, // 30度
        distanceThreshold: Float = 0.02, // 2cm
        directionToleranceRadians: Float = .pi / 4 // 45度
    ) {
        self.handTrackingComponent = handTrackingComponent
        self.handKind = handKind
        self.angleToleranceRadians = angleToleranceRadians
        self.distanceThreshold = distanceThreshold
        self.directionToleranceRadians = directionToleranceRadians

        // 事前計算
        self.palmNormal = Self.calculatePalmNormal(from: handTrackingComponent)
        self.forearmDirection = Self.calculateForearmDirection(from: handTrackingComponent)
        self.wristPosition = Self.getWristPosition(from: handTrackingComponent)
        self.isArmExtended = Self.calculateArmExtension(from: handTrackingComponent, tolerance: angleToleranceRadians)
        }
}

// MARK: - 1. Public Getters and Functions Extension
public extension SingleHandGestureData {

    // MARK: - 指や手のひらの方向判定

    /// 手のひらが現在向いている方向を取得する
    /// 例：手のひらを上に向けている場合は.topを返す
    var palmDirection: GestureDetectionDirection {
        // HandTrackingComponentのgetPalmDirection()と同じロジックを使用
        let palmDir = handTrackingComponent.getPalmDirection()
        
        // PalmDirectionからGestureDetectionDirectionに変換
        switch palmDir {
        case .up: return .top
        case .down: return .bottom
        case .left: return .left
        case .right: return .right
        case .forward: return .forward
        case .backward: return .backward
        case .unknown: return .forward // デフォルト
        }
    }

    /// 手のひらが指定した方向を向いているかを判定する
    /// 例：isPalmFacing(.top)で手のひらが上向きかチェック
    func isPalmFacing(_ direction: GestureDetectionDirection) -> Bool {
        // palmDirectionプロパティと同じ判定を使用して一貫性を保つ
        return palmDirection == direction
    }

    /// 指定した指が向いている方向を取得する
    /// 指先と中間関節の位置から指の向きベクトルを計算する
    func fingerDirection(for finger: FingerType) -> GestureDetectionDirection {
        guard let tipJoint = getFingerTipJoint(for: finger),
              let intermediateJoint = getFingerIntermediateJoint(for: finger),
              let tipEntity = handTrackingComponent.fingers[tipJoint],
              let intermediateEntity = handTrackingComponent.fingers[intermediateJoint] else {
            return .forward // デフォルト値
        }

        let tipPos = tipEntity.position(relativeTo: nil)
        let intermediatePos = intermediateEntity.position(relativeTo: nil)
        let fingerVector = simd_normalize(tipPos - intermediatePos)

        return vectorToGestureDirection(fingerVector)
    }

    /// 指定した指が特定の方向を指しているかを判定する
    /// 例：isFingerPointing(.index, direction: .top)で人差し指が上を指しているかチェック
    /// - Parameters:
    ///   - finger: 判定したい指
    ///   - direction: 期待する方向
    ///   - tolerance: 許容角度（ラジアン）。nilの場合はdirectionToleranceRadiansを使用
    func isFingerPointing(_ finger: FingerType, direction: GestureDetectionDirection, tolerance: Float? = nil) -> Bool {
        guard let tipJoint = getFingerTipJoint(for: finger),
              let intermediateJoint = getFingerIntermediateJoint(for: finger),
              let tipEntity = handTrackingComponent.fingers[tipJoint],
              let intermediateEntity = handTrackingComponent.fingers[intermediateJoint] else {
            return false
        }

        let tipPos = tipEntity.position(relativeTo: nil)
        let intermediatePos = intermediateEntity.position(relativeTo: nil)
        let fingerVector = simd_normalize(tipPos - intermediatePos)

        return isVectorFacing(fingerVector, direction: direction, tolerance: tolerance)
    }

    // MARK: - 指の曲がり判定

    /// 指定した指が曲がっているかを判定する（握り拳のような状態）
    /// 関節角度が設定した許容値を超えて曲がっている場合にtrueを返す
    func isFingerBent(_ finger: FingerType) -> Bool {
        return handTrackingComponent.isFingerBent(finger, tolerance: angleToleranceRadians)
    }

    /// 指定した指が真っ直ぐ伸びているかを判定する
    /// 関節角度が設定した許容値以内で直線に近い場合にtrueを返す
    func isFingerStraight(_ finger: FingerType) -> Bool {
        // HandTrackingComponent拡張のisFingerStraightメソッドを呼び出す
        // toleranceは45度（.pi/4）に統一
        return handTrackingComponent.isFingerStraight(finger, tolerance: .pi / 4)
    }
    
    /// 指の曲がり具合を段階的に判定する
    public enum FingerBendLevel {
        case straight      // 完全に伸びている（0〜30度）
        case slightlyBent  // 軽く曲がっている（30〜60度）
        case moderatelyBent // 中程度に曲がっている（60〜90度）
        case heavilyBent   // かなり曲がっている（90〜120度）
        case fullyBent     // 完全に曲がっている（120度以上）
    }
    
    /// 指定した指の曲がり具合レベルを取得する
    func getFingerBendLevel(_ finger: FingerType) -> FingerBendLevel {
        // 完全に伸びている（30度以内）
        if handTrackingComponent.isFingerStraight(finger, tolerance: .pi / 6) {
            return .straight
        }
        // 軽く曲がっている（60度以内）
        else if handTrackingComponent.isFingerStraight(finger, tolerance: .pi / 3) {
            return .slightlyBent
        }
        // 中程度に曲がっている（90度以内）
        else if handTrackingComponent.isFingerStraight(finger, tolerance: .pi / 2) {
            return .moderatelyBent
        }
        // かなり曲がっている（120度以内）
        else if handTrackingComponent.isFingerStraight(finger, tolerance: 2 * .pi / 3) {
            return .heavilyBent
        }
        // 完全に曲がっている（120度以上）
        else {
            return .fullyBent
        }
    }
    
    /// 指定した指が特定の曲がり具合レベルかを判定する
    func isFingerAtBendLevel(_ finger: FingerType, level: FingerBendLevel) -> Bool {
        return getFingerBendLevel(finger) == level
    }
    
    /// 指定した指が最小レベル以上に曲がっているかを判定する
    func isFingerBentAtLeast(_ finger: FingerType, minimumLevel: FingerBendLevel) -> Bool {
        let currentLevel = getFingerBendLevel(finger)
        switch minimumLevel {
        case .straight:
            return true // 常にtrue
        case .slightlyBent:
            return currentLevel != .straight
        case .moderatelyBent:
            return currentLevel == .moderatelyBent || currentLevel == .heavilyBent || currentLevel == .fullyBent
        case .heavilyBent:
            return currentLevel == .heavilyBent || currentLevel == .fullyBent
        case .fullyBent:
            return currentLevel == .fullyBent
        }
    }

    /// すべての指が曲がっているかを判定する（握り拳状態の検出）
    /// 親指、人差し指、中指、薬指、小指すべてが曲がっている場合にtrueを返す
    var isAllFingersBent: Bool {
        let fingers: [FingerType] = [.thumb, .index, .middle, .ring, .little]
        return fingers.allSatisfy { isFingerBent($0) }
    }

    /// 指定した指以外がすべて曲がっているかを判定する
    /// 例：人差し指だけを立てて他を曲げている状態の検出に使用
    func areAllFingersExceptBent(_ exceptFingers: [FingerType]) -> Bool {
        let allFingers: [FingerType] = [.thumb, .index, .middle, .ring, .little]
        let fingersToCheck = allFingers.filter { !exceptFingers.contains($0) }
        return fingersToCheck.allSatisfy { isFingerBent($0) }
    }

    // MARK: - 手首の曲がり判定

    /// 手首が外側（甲側）に曲がっているかを判定する
    /// 前腕と手のひらの角度が90度より大きく開いている状態を検出
    var isWristBentOutward: Bool {
        guard let wrist = handTrackingComponent.fingers[.wrist],
              let middleMCP = handTrackingComponent.fingers[.middleFingerMetacarpal] else {
            return false
        }

        let wristPos = wrist.position(relativeTo: nil)
        let middlePos = middleMCP.position(relativeTo: nil)

        // 手の向きと前腕の向きを比較
        let handVector = simd_normalize(middlePos - wristPos)
        let angle = acos(max(-1.0, min(1.0, simd_dot(handVector, forearmDirection))))

        // 90度より大きく曲がっている場合を外側とみなす
        return angle > (.pi / 2 + angleToleranceRadians)
    }

    /// 手首が内側（手のひら側）に曲がっているかを判定する
    /// 前腕と手のひらの角度が90度より小さく折れている状態を検出
    var isWristBentInward: Bool {
        guard let wrist = handTrackingComponent.fingers[.wrist],
              let middleMCP = handTrackingComponent.fingers[.middleFingerMetacarpal] else {
            return false
        }

        let wristPos = wrist.position(relativeTo: nil)
        let middlePos = middleMCP.position(relativeTo: nil)

        // 手の向きと前腕の向きを比較
        let handVector = simd_normalize(middlePos - wristPos)
        let angle = acos(max(-1.0, min(1.0, simd_dot(handVector, forearmDirection))))

        // 90度より小さく曲がっている場合を内側とみなす
        return angle < (.pi / 2 - angleToleranceRadians)
    }

    /// 手首がまっすぐ（自然な位置）かを判定する
    /// 内側にも外側にも曲がっていない中立的な状態を検出
    var isWristStraight: Bool {
        return !isWristBentInward && !isWristBentOutward
    }

    // MARK: - 腕の伸展状態

    /// 腕が伸ばされているかを判定する（事前計算済み）
    /// 前腕-手首-手のひらが直線に近い状態（180度に近い角度）の場合にtrueを返す
    var armExtended: Bool {
        return isArmExtended
    }

    // MARK: - 腕の伸展方向

    /// 腕が伸ばされている方向を取得する
    /// 前腕の向きベクトルから最も強い方向成分を判定して返す
    var armDirection: GestureDetectionDirection {
        return vectorToGestureDirection(forearmDirection)
    }

    /// 腕が特定の方向に伸ばされているかを判定する
    /// 腕が伸展状態かつ指定した方向を向いている場合にtrueを返す
    /// 例：isArmExtendedInDirection(.top)で腕を上に挙げているかチェック
    func isArmExtendedInDirection(_ direction: GestureDetectionDirection) -> Bool {
        return armExtended && isVectorFacing(forearmDirection, direction: direction)
    }
}

// MARK: - 2. Static Helper Methods Extension (Private)
private extension SingleHandGestureData {

    // MARK: - Private Static Helper Methods for Pre-computation（事前計算用メソッド）

    /// 手のひらの法線ベクトルを計算する（初期化時に実行）
    /// 手首、人差し指の付け根、小指の付け根の3点から手のひら平面の法線を求める
    static func calculatePalmNormal(from component: HandTrackingComponent) -> SIMD3<Float> {
        guard let wrist = component.fingers[.wrist],
              let indexMCP = component.fingers[.indexFingerMetacarpal],
              let littleMCP = component.fingers[.littleFingerMetacarpal] else {
            return SIMD3<Float>(0, 0, 1) // デフォルト値
        }

        let wristPos = wrist.position(relativeTo: nil)
        let indexPos = indexMCP.position(relativeTo: nil)
        let littlePos = littleMCP.position(relativeTo: nil)

        let v1 = indexPos - wristPos
        let v2 = littlePos - wristPos
        let normal = simd_cross(v1, v2)

        return simd_normalize(normal)
    }

    /// 前腕の方向ベクトルを計算する（初期化時に実行）
    /// 前腕関節から手首への方向を求めて、腕の向きとして使用
    static func calculateForearmDirection(from component: HandTrackingComponent) -> SIMD3<Float> {
        guard let wrist = component.fingers[.wrist],
              let forearm = component.fingers[.forearmArm] else {
            return SIMD3<Float>(0, 1, 0) // デフォルト値（上向き）
        }

        let wristPos = wrist.position(relativeTo: nil)
        let forearmPos = forearm.position(relativeTo: nil)

        return simd_normalize(wristPos - forearmPos)
    }

    /// 手首の位置を取得する（初期化時に実行）
    /// 各種計算で基準点として使用される
    static func getWristPosition(from component: HandTrackingComponent) -> SIMD3<Float> {
        return component.fingers[.wrist]?.position(relativeTo: nil) ?? SIMD3<Float>.zero
    }

    /// 腕の伸展状態を計算する（初期化時に実行）
    /// 前腕-手首-手のひらの3点が直線に近いかどうかを角度で判定
    static func calculateArmExtension(from component: HandTrackingComponent, tolerance: Float) -> Bool {
        guard let wrist = component.fingers[.wrist],
              let forearm = component.fingers[.forearmArm],
              let middleMCP = component.fingers[.middleFingerMetacarpal] else {
            return false
        }

        let wristPos = wrist.position(relativeTo: nil)
        let forearmPos = forearm.position(relativeTo: nil)
        let middlePos = middleMCP.position(relativeTo: nil)

        // 前腕-手首-手のひらの角度を計算
        let v1 = simd_normalize(forearmPos - wristPos)
        let v2 = simd_normalize(middlePos - wristPos)

        let angle = acos(max(-1.0, min(1.0, simd_dot(v1, v2))))

        // 直線に近い場合（180度に近い）を伸展とみなす
        return abs(angle - .pi) <= tolerance
    }
    
    /// すべての指が伸びているかをチェック
    /// - Returns: すべての指が伸びている場合true
    public func areAllFingersExtended() -> Bool {
        let fingers: [FingerType] = [.thumb, .index, .middle, .ring, .little]
        return fingers.allSatisfy { isFingerStraight($0) }
    }
    
    /// 指先の一般的な方向を取得（複数の指の平均）
    /// - Returns: 指先の平均的な方向
    public func fingerTipsGeneralDirection() -> GestureDetectionDirection {
        let fingers: [FingerType] = [.index, .middle, .ring, .little] // 親指を除く
        let directions = fingers.map { fingerDirection(for: $0) }
        
        // 最も頻出する方向を返す
        let directionCounts = directions.reduce(into: [:]) { counts, direction in
            counts[direction, default: 0] += 1
        }
        
        return directionCounts.max(by: { $0.value < $1.value })?.key ?? .forward
    }
}

// MARK: - 3. Private Instance Helper Methods Extension
private extension SingleHandGestureData {

    // MARK: - 方向変換ヘルパー

    /// 3Dベクトルから最も強い方向成分を判定してGestureDetectionDirectionに変換する
    /// 例：上向きのベクトル(0, 1, 0)なら.topを返す
    func vectorToGestureDirection(_ vector: SIMD3<Float>) -> GestureDetectionDirection {
        let absX = abs(vector.x)
        let absY = abs(vector.y)
        let absZ = abs(vector.z)

        // 最も大きな成分で方向を決定
        if absY > absX && absY > absZ {
            return vector.y > 0 ? .top : .bottom
        } else if absZ > absX && absZ > absY {
            return vector.z > 0 ? .backward : .forward
        } else {
            return vector.x > 0 ? .right : .left
        }
    }

    /// 指定したベクトルが特定の方向を向いているかを角度で判定する
    /// 設定した許容角度（directionToleranceRadians）以内なら一致とみなす
    func isVectorFacing(_ vector: SIMD3<Float>, direction: GestureDetectionDirection, tolerance: Float? = nil) -> Bool {
        let targetVector: SIMD3<Float>
        switch direction {
        case .top: targetVector = SIMD3<Float>(0, 1, 0)      // 上方向
        case .bottom: targetVector = SIMD3<Float>(0, -1, 0)  // 下方向
        case .forward: targetVector = SIMD3<Float>(0, 0, -1) // 前方向
        case .backward: targetVector = SIMD3<Float>(0, 0, 1) // 後方向
        case .right: targetVector = SIMD3<Float>(1, 0, 0)    // 右方向
        case .left: targetVector = SIMD3<Float>(-1, 0, 0)    // 左方向
        }

        let normalizedVector = simd_normalize(vector)
        let dotProduct = simd_dot(normalizedVector, targetVector)
        let angle = acos(max(-1.0, min(1.0, dotProduct)))

        let effectiveTolerance = tolerance ?? directionToleranceRadians
        return angle <= effectiveTolerance
    }

    // MARK: - Helper Methods（内部補助メソッド）

    /// 指定した指の先端関節名を取得するヘルパーメソッド
    /// 指の向きを計算する際に使用される
    func getFingerTipJoint(for finger: FingerType) -> HandSkeleton.JointName? {
        switch finger {
        case .thumb: return .thumbTip
        case .index: return .indexFingerTip
        case .middle: return .middleFingerTip
        case .ring: return .ringFingerTip
        case .little: return .littleFingerTip
        }
    }

    /// 指定した指の中間関節名を取得するヘルパーメソッド
    /// 指の向きベクトルを計算する際に先端関節とペアで使用される
    func getFingerIntermediateJoint(for finger: FingerType) -> HandSkeleton.JointName? {
        switch finger {
        case .thumb: return .thumbIntermediateTip
        case .index: return .indexFingerIntermediateTip
        case .middle: return .middleFingerIntermediateTip
        case .ring: return .ringFingerIntermediateTip
        case .little: return .littleFingerIntermediateTip
        }
    }
}