//
//  HandsGestureData.swift
//  HandGesturePackage
//
//  Created by Claude on 2025/07/26.
//

import Foundation
import RealityKit
import ARKit
import simd

/// 両手のジェスチャーデータを保持する構造体
public struct HandsGestureData {
    /// 左手のジェスチャーデータ
    public let leftHand: SingleHandGestureData
    
    /// 右手のジェスチャーデータ
    public let rightHand: SingleHandGestureData
    
    /// 初期化メソッド
    public init(leftHand: SingleHandGestureData, rightHand: SingleHandGestureData) {
        self.leftHand = leftHand
        self.rightHand = rightHand
    }
}

// MARK: - 両手間の関係性を計算するメソッド
public extension HandsGestureData {
    
    /// 両手の手のひらの間の距離を取得
    var palmDistance: Float {
        let leftPalmPos = leftHand.handTrackingComponent.fingers[.wrist]?.position(relativeTo: nil) ?? .zero
        let rightPalmPos = rightHand.handTrackingComponent.fingers[.wrist]?.position(relativeTo: nil) ?? .zero
        return simd_distance(leftPalmPos, rightPalmPos)
    }
    
    /// 特定の関節の3D位置を取得
    func getJointPosition(hand: HandKind, joint: HandSkeleton.JointName) -> SIMD3<Float>? {
        let component = hand == .left ? leftHand.handTrackingComponent : rightHand.handTrackingComponent
        return component.fingers[joint]?.position(relativeTo: nil)
    }
    
    /// 両手の同じ関節間の距離を取得
    func jointDistance(joint: HandSkeleton.JointName) -> Float {
        guard let leftPos = getJointPosition(hand: .left, joint: joint),
              let rightPos = getJointPosition(hand: .right, joint: joint) else {
            return Float.infinity
        }
        return simd_distance(leftPos, rightPos)
    }
    
    /// 両手の対応する指の関節間の距離を取得
    func correspondingFingerJointDistance(leftJoint: HandSkeleton.JointName, rightJoint: HandSkeleton.JointName) -> Float {
        guard let leftPos = getJointPosition(hand: .left, joint: leftJoint),
              let rightPos = getJointPosition(hand: .right, joint: rightJoint) else {
            return Float.infinity
        }
        return simd_distance(leftPos, rightPos)
    }
    
    /// 両手の手のひらの中心位置間の距離を取得（より正確な手のひらの距離）
    var palmCenterDistance: Float {
        // 手のひらの中心を指の付け根の平均位置として計算
        // 注: knuckleは指の最初の関節（MCP関節）を指す
        guard let leftThumbKnuckle = getJointPosition(hand: .left, joint: .thumbKnuckle),
              let leftIndexKnuckle = getJointPosition(hand: .left, joint: .indexFingerKnuckle),
              let leftMiddleKnuckle = getJointPosition(hand: .left, joint: .middleFingerKnuckle),
              let leftRingKnuckle = getJointPosition(hand: .left, joint: .ringFingerKnuckle),
              let leftLittleKnuckle = getJointPosition(hand: .left, joint: .littleFingerKnuckle),
              let rightThumbKnuckle = getJointPosition(hand: .right, joint: .thumbKnuckle),
              let rightIndexKnuckle = getJointPosition(hand: .right, joint: .indexFingerKnuckle),
              let rightMiddleKnuckle = getJointPosition(hand: .right, joint: .middleFingerKnuckle),
              let rightRingKnuckle = getJointPosition(hand: .right, joint: .ringFingerKnuckle),
              let rightLittleKnuckle = getJointPosition(hand: .right, joint: .littleFingerKnuckle) else {
            return Float.infinity
        }
        
        // 左手の手のひら中心（5本の指の付け根の平均）
        let leftPalmCenter = (leftThumbKnuckle + leftIndexKnuckle + leftMiddleKnuckle + leftRingKnuckle + leftLittleKnuckle) / 5
        
        // 右手の手のひら中心（5本の指の付け根の平均）
        let rightPalmCenter = (rightThumbKnuckle + rightIndexKnuckle + rightMiddleKnuckle + rightRingKnuckle + rightLittleKnuckle) / 5
        
        return simd_distance(leftPalmCenter, rightPalmCenter)
    }
    
    /// 両手の中指の付け根間の距離（シンプルな手のひら距離）
    var middleKnuckleDistance: Float {
        return jointDistance(joint: .middleFingerKnuckle)
    }
    
    /// 両手の垂直方向のズレを取得（Y軸の差）
    var verticalOffset: Float {
        guard let leftWrist = getJointPosition(hand: .left, joint: .wrist),
              let rightWrist = getJointPosition(hand: .right, joint: .wrist) else {
            return Float.infinity
        }
        return abs(leftWrist.y - rightWrist.y)
    }
    
    /// 両手の特定の指先間の距離を取得
    func fingerTipDistance(leftFinger: FingerType, rightFinger: FingerType) -> Float {
        guard let leftJoint = getFingerTipJoint(for: leftFinger),
              let rightJoint = getFingerTipJoint(for: rightFinger),
              let leftEntity = leftHand.handTrackingComponent.fingers[leftJoint],
              let rightEntity = rightHand.handTrackingComponent.fingers[rightJoint] else {
            return Float.infinity
        }
        
        let leftPos = leftEntity.position(relativeTo: nil)
        let rightPos = rightEntity.position(relativeTo: nil)
        return simd_distance(leftPos, rightPos)
    }
    
    /// 両手の手のひらが向かい合っているかを判定
    var arePalmsFacingEachOther: Bool {
        // 左手の法線と右手の法線の内積が負の場合、向かい合っている
        let leftNormal = getNormalizedPalmNormal(for: leftHand)
        let rightNormal = getNormalizedPalmNormal(for: rightHand)
        let dotProduct = simd_dot(leftNormal, rightNormal)
        
        // -0.7以下なら約135度以上の角度で向かい合っている
        return dotProduct < -0.7
    }
    
    /// 両手が平行になっているかを判定
    var areHandsParallel: Bool {
        let leftNormal = getNormalizedPalmNormal(for: leftHand)
        let rightNormal = getNormalizedPalmNormal(for: rightHand)
        let dotProduct = abs(simd_dot(leftNormal, rightNormal))
        
        // 0.9以上なら約25度以内で平行
        return dotProduct > 0.9
    }
    
    /// 両手の中心位置を取得
    var centerPosition: SIMD3<Float> {
        let leftPos = leftHand.handTrackingComponent.fingers[.wrist]?.position(relativeTo: nil) ?? .zero
        let rightPos = rightHand.handTrackingComponent.fingers[.wrist]?.position(relativeTo: nil) ?? .zero
        return (leftPos + rightPos) / 2
    }
    
    // MARK: - Helper Methods
    
    private func getFingerTipJoint(for finger: FingerType) -> HandSkeleton.JointName? {
        switch finger {
        case .thumb: return .thumbTip
        case .index: return .indexFingerTip
        case .middle: return .middleFingerTip
        case .ring: return .ringFingerTip
        case .little: return .littleFingerTip
        }
    }
    
    private func getNormalizedPalmNormal(for hand: SingleHandGestureData) -> SIMD3<Float> {
        guard let wrist = hand.handTrackingComponent.fingers[.wrist],
              let indexKnuckle = hand.handTrackingComponent.fingers[.indexFingerKnuckle],
              let littleKnuckle = hand.handTrackingComponent.fingers[.littleFingerKnuckle] else {
            return SIMD3<Float>(0, 0, 1)
        }
        
        let wristPos = wrist.position(relativeTo: nil)
        let indexPos = indexKnuckle.position(relativeTo: nil)
        let littlePos = littleKnuckle.position(relativeTo: nil)
        
        let v1 = indexPos - wristPos
        let v2 = littlePos - wristPos
        let normal = simd_cross(v1, v2)
        
        // 左右の手で法線の向きを調整
        let normalizedNormal = simd_normalize(normal)
        
        // 右手の場合は法線を反転（手のひらが内側を向くように）
        if hand.handKind == .right {
            return -normalizedNormal
        }
        
        return normalizedNormal
    }
    
    // MARK: - 位置検証ヘルパーメソッド
    
    /// 手が目線から指定の距離にあるかをチェック
    /// - Parameters:
    ///   - hand: 対象の手（左右）
    ///   - fromEyeLevel: 目線からの距離（メートル）
    ///   - tolerance: 許容誤差（メートル）
    /// - Returns: 指定範囲内にある場合true
    public func isHandAtRelativeHeight(hand: HandKind, fromEyeLevel: Float, tolerance: Float = 0.05) -> Bool {
        // 注意: 実際の目線の高さは取得できないため、相対的な位置で判定
        // デバイスの基準点（通常は初期位置）からの高さを使用
        guard let wristPos = getJointPosition(hand: hand, joint: .wrist) else {
            return false
        }
        
        // 基準となる高さ（仮に1.5mを目線の高さとする）
        let eyeLevel: Float = 1.5
        let targetHeight = eyeLevel - fromEyeLevel
        
        // Y座標で判定
        let difference = abs(wristPos.y - targetHeight)
        return difference <= tolerance
    }
    
    /// 両手の垂直方向の距離を取得
    /// - Returns: 垂直方向の距離（メートル）。右手が上の場合は正の値
    public func handVerticalSeparation() -> Float {
        guard let leftWrist = getJointPosition(hand: .left, joint: .wrist),
              let rightWrist = getJointPosition(hand: .right, joint: .wrist) else {
            return 0
        }
        return rightWrist.y - leftWrist.y
    }
    
    /// 指定した関節が別の関節の近くにあるかをチェック
    /// - Parameters:
    ///   - joint1: 最初の関節
    ///   - hand1: 最初の手
    ///   - joint2: 二番目の関節
    ///   - hand2: 二番目の手
    ///   - maxDistance: 最大距離（メートル）
    /// - Returns: 指定距離内にある場合true
    public func areJointsClose(
        joint1: HandSkeleton.JointName,
        hand1: HandKind,
        joint2: HandSkeleton.JointName,
        hand2: HandKind,
        maxDistance: Float
    ) -> Bool {
        guard let pos1 = getJointPosition(hand: hand1, joint: joint1),
              let pos2 = getJointPosition(hand: hand2, joint: joint2) else {
            return false
        }
        return simd_distance(pos1, pos2) <= maxDistance
    }
    
    /// 異なる手の特定の関節間の距離を取得
    /// - Parameters:
    ///   - joint1: 最初の関節
    ///   - hand1: 最初の手
    ///   - joint2: 二番目の関節
    ///   - hand2: 二番目の手
    /// - Returns: 関節間の距離（メートル）。関節が見つからない場合はFloat.infinity
    public func jointToJointDistance(
        joint1: HandSkeleton.JointName,
        hand1: HandKind,
        joint2: HandSkeleton.JointName,
        hand2: HandKind
    ) -> Float {
        guard let pos1 = getJointPosition(hand: hand1, joint: joint1),
              let pos2 = getJointPosition(hand: hand2, joint: joint2) else {
            return Float.infinity
        }
        return simd_distance(pos1, pos2)
    }
}