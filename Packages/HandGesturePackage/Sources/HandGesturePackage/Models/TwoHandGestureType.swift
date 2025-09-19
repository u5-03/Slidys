//
//  TwoHandGestureType.swift
//  HandGesturePackage
//
//  Created by yugo.sugiyama on 2025/06/05.
//

import ARKit
import Foundation
import simd

// MARK: - 両手ジェスチャーの定義

@MainActor
public enum TwoHandGestureType: CaseIterable {
    case palmsTogetherRightAngleArmsHorizontal
    case rightFistAboveLeftOpenHand
    case fingersBent90Degrees
    case rightArmVerticalLeftArmHorizontalFingertipsTouch
    // 必要に応じて両手ジェスチャーを追加

    public func matches(handData: HandGestureData) -> Bool {
        switch self {
        case .palmsTogetherRightAngleArmsHorizontal:
            // 1. 両手のひらが触れ合い、手首が直角、前腕が水平(y座標がほぼ等しい)
            let leftPalm = handData.leftPalmWorldPosition
            let rightPalm = handData.rightPalmWorldPosition
            // 手のひら間の距離がほぼゼロ
            guard simd_distance(leftPalm, rightPalm) < HandGestureType.distanceTolerance * 2 else {
                return false
            }
            // 左手首から前腕へのベクトルが水平かチェック(y差が小さい)
            let leftWristToForearm =
                handData.leftWristWorldPosition - handData.leftForearmWorldPosition
            // 水平とはy成分 ≈ 0を意味する
            guard abs(leftWristToForearm.y) < HandGestureType.distanceTolerance * 2 else {
                return false
            }
            // 右手首から前腕へのベクトルが水平かチェック
            let rightWristToForearm =
                handData.rightWristWorldPosition - handData.rightForearmWorldPosition
            guard abs(rightWristToForearm.y) < HandGestureType.distanceTolerance * 2 else {
                return false
            }
            // 手のひらが向かい合っているかチェック(法線が反対方向を向いている)
            let leftPalmNormal = handData.leftPalmNormal
            let rightPalmNormal = handData.rightPalmNormal
            let dotProduct = simd_dot(leftPalmNormal, rightPalmNormal)
            return dotProduct < -0.7  // ほぼ反対方向

        case .rightFistAboveLeftOpenHand:
            // 2. 右手が握りこぶし、左手が完全に開いた状態、腕は水平、右のこぶしが左の開いた手の上にある
            // 右手のこぶしをチェック
            let rightHandData = HandGestureData(
                leftJointWorldPositions: [:],
                leftPalmWorldPosition: .zero,
                leftPalmNormal: .zero,
                leftWristWorldPosition: .zero,
                leftForearmWorldPosition: .zero,
                rightJointWorldPositions: handData.rightJointWorldPositions,
                rightPalmWorldPosition: handData.rightPalmWorldPosition,
                rightPalmNormal: handData.rightPalmNormal,
                rightWristWorldPosition: handData.rightWristWorldPosition,
                rightForearmWorldPosition: handData.rightForearmWorldPosition
            )
            if !HandGestureType.fist.matches(handGestureData: rightHandData, chirality: .right) {
                return false
            }
            // 左手の開いた状態をチェック
            let leftHandData = HandGestureData(
                leftJointWorldPositions: handData.leftJointWorldPositions,
                leftPalmWorldPosition: handData.leftPalmWorldPosition,
                leftPalmNormal: handData.leftPalmNormal,
                leftWristWorldPosition: handData.leftWristWorldPosition,
                leftForearmWorldPosition: handData.leftForearmWorldPosition,
                rightJointWorldPositions: [:],
                rightPalmWorldPosition: .zero,
                rightPalmNormal: .zero,
                rightWristWorldPosition: .zero,
                rightForearmWorldPosition: .zero
            )
            if !HandGestureType.openHand.matches(handGestureData: leftHandData, chirality: .left) {
                return false
            }
            // 両前腕が水平：手首のy位置 ≈ 対応する前腕のy位置
            guard
                abs(handData.rightWristWorldPosition.y - handData.rightForearmWorldPosition.y)
                    < HandGestureType.distanceTolerance * 2,
                abs(handData.leftWristWorldPosition.y - handData.leftForearmWorldPosition.y)
                    < HandGestureType.distanceTolerance * 2
            else {
                return false
            }
            // 右手のひらが左手のひらより上にあるかチェック(y座標が高い)
            return handData.rightPalmWorldPosition.y > handData.leftPalmWorldPosition.y
                + HandGestureType.distanceTolerance

        case .fingersBent90Degrees:
            // 3. すべての指関節が手のひらに対してほぼ90度の角度(各指の中間角度をチェック)
            // 両手をチェック
            let allJoints = handData.rightJointWorldPositions.merging(
                handData.leftJointWorldPositions
            ) { (_, new) in new }

            for (jointName, jointPos) in allJoints {
                // 中間指関節のみをチェック(例：ナックル、中間ベース)
                if jointName.isIntermediateJoint {
                    let parentJoint = jointName.parentJoint
                    let childJoint = jointName.childJoint
                    guard let parentPos = allJoints[parentJoint],
                        let childPos = allJoints[childJoint]
                    else {
                        continue
                    }
                    let v1 = simd_normalize(parentPos - jointPos)
                    let v2 = simd_normalize(childPos - jointPos)
                    let angle = acos(max(-1, min(1, simd_dot(v1, v2))))
                    if abs(angle - (.pi / 2)) > HandGestureType.angleTolerance * 2 {
                        return false
                    }
                }
            }
            return true

        case .rightArmVerticalLeftArmHorizontalFingertipsTouch:
            // 4. 右腕が垂直で指がまっすぐ、左腕が水平で指がまっすぐ、両手の指先が触れ合っている
            // 右腕が垂直かチェック：前腕と手首のベクトルが主に垂直
            let rightWristToForearm =
                handData.rightWristWorldPosition - handData.rightForearmWorldPosition
            guard abs(rightWristToForearm.x) < HandGestureType.distanceTolerance * 2,
                rightWristToForearm.y > HandGestureType.distanceTolerance,
                abs(rightWristToForearm.z) < HandGestureType.distanceTolerance * 2
            else {
                return false
            }
            // 右手が開いているかチェック(まっすぐな指)
            let rightHandData = HandGestureData(
                leftJointWorldPositions: [:],
                leftPalmWorldPosition: .zero,
                leftPalmNormal: .zero,
                leftWristWorldPosition: .zero,
                leftForearmWorldPosition: .zero,
                rightJointWorldPositions: handData.rightJointWorldPositions,
                rightPalmWorldPosition: handData.rightPalmWorldPosition,
                rightPalmNormal: handData.rightPalmNormal,
                rightWristWorldPosition: handData.rightWristWorldPosition,
                rightForearmWorldPosition: handData.rightForearmWorldPosition
            )
            if !HandGestureType.openHand.matches(handGestureData: rightHandData, chirality: .right)
            {
                return false
            }
            // 左腕が水平かチェック：前腕と手首のベクトルが主に水平
            let leftWristToForearm =
                handData.leftWristWorldPosition - handData.leftForearmWorldPosition
            guard abs(leftWristToForearm.y) < HandGestureType.distanceTolerance * 2 else {
                return false
            }
            // 左手が開いているかチェック
            let leftHandData = HandGestureData(
                leftJointWorldPositions: handData.leftJointWorldPositions,
                leftPalmWorldPosition: handData.leftPalmWorldPosition,
                leftPalmNormal: handData.leftPalmNormal,
                leftWristWorldPosition: handData.leftWristWorldPosition,
                leftForearmWorldPosition: handData.leftForearmWorldPosition,
                rightJointWorldPositions: [:],
                rightPalmWorldPosition: .zero,
                rightPalmNormal: .zero,
                rightWristWorldPosition: .zero,
                rightForearmWorldPosition: .zero
            )
            if !HandGestureType.openHand.matches(handGestureData: leftHandData, chirality: .left) {
                return false
            }
            // 指先が触れ合っている：対応する指先間の距離がほぼゼロ
            for fingertip in HandSkeleton.JointName.allFingertipJoints {
                guard let leftTip = handData.leftJointWorldPositions[fingertip],
                    let rightTip = handData.rightJointWorldPositions[fingertip]
                else {
                    return false
                }
                if simd_distance(leftTip, rightTip) > HandGestureType.distanceTolerance * 2 {
                    return false
                }
            }
            return true
        }
    }
}
