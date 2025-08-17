//
//  HandGestureType.swift
//  HandGesturePackage
//
//  Created by yugo.sugiyama on 2025/06/05.
//

import ARKit
import simd
import Foundation

// MARK: - 片手ジェスチャーの定義

@MainActor
public enum HandGestureType: CaseIterable {
    case fist
    case openHand
    case pointIndex
    case custom1
    case custom2
    // 必要に応じてジェスチャータイプを追加

    // 角度と距離を比較するための許容値
    static let angleTolerance: Float = 15.0 * .pi / 180.0 // 15度をラジアンで表現
    static let distanceTolerance: Float = 0.02 // 2cm

    /// 指定された関節と手のひらのデータがこのジェスチャーを満たすかどうかを返す
    func matches(handGestureData: HandGestureData, chirality: HandAnchor.Chirality) -> Bool {
        let jointWorldPositions: [HandSkeleton.JointName: SIMD3<Float>]
        let palmWorldPosition: SIMD3<Float>
        let palmNormal: SIMD3<Float>

        switch chirality {
        case .left:
            jointWorldPositions = handGestureData.leftJointWorldPositions
            palmWorldPosition = handGestureData.leftPalmWorldPosition
            palmNormal = handGestureData.leftPalmNormal
        case .right:
            jointWorldPositions = handGestureData.rightJointWorldPositions
            palmWorldPosition = handGestureData.rightPalmWorldPosition
            palmNormal = handGestureData.rightPalmNormal
        @unknown default:
            return false
        }

        switch self {
        case .fist:
            // すべての指が曲がっている：各指先がその基部関節の近くにある
            for finger in HandSkeleton.JointName.allFingertipJoints {
                let tipPosition = jointWorldPositions[finger] ?? simd_float3.zero
                let basePosition = jointWorldPositions[finger.baseJoint] ?? simd_float3.zero
                if simd_distance(tipPosition, basePosition) > HandGestureType.distanceTolerance * 3 {
                    return false
                }
            }
            return true

        case .openHand:
            // すべての指が伸びている：各指先が手のひらの中心から十分に離れている
            for finger in HandSkeleton.JointName.allFingertipJoints {
                let tipPosition = jointWorldPositions[finger] ?? simd_float3.zero
                if simd_distance(tipPosition, palmWorldPosition) < HandGestureType.distanceTolerance * 5 {
                    return false
                }
            }
            return true

        case .pointIndex:
            // 人差し指が伸びて他の指が曲がっている
            guard let indexTip = jointWorldPositions[.indexFingerTip],
                  let indexBase = jointWorldPositions[.indexFingerMetacarpal],
                  let middleTip = jointWorldPositions[.middleFingerTip],
                  let middleBase = jointWorldPositions[.middleFingerMetacarpal],
                  let ringTip = jointWorldPositions[.ringFingerTip],
                  let ringBase = jointWorldPositions[.ringFingerMetacarpal] else {
                return false
            }
            // 人差し指が伸びている
            if simd_distance(indexTip, indexBase) < HandGestureType.distanceTolerance * 3 {
                return false
            }
            // 他の指が基部の近くにある
            if simd_distance(middleTip, middleBase) > HandGestureType.distanceTolerance * 2 ||
                simd_distance(ringTip, ringBase) > HandGestureType.distanceTolerance * 2 {
                return false
            }
            return true

        case .custom1:
            // カスタム例：親指と小指が触れている（「電話して」のサイン）
            guard let thumbTip = jointWorldPositions[.thumbTip],
                  let pinkyTip = jointWorldPositions[.littleFingerTip] else {
                return false
            }
            return simd_distance(thumbTip, pinkyTip) < HandGestureType.distanceTolerance * 2

        case .custom2:
            // カスタム例：手のひらがカメラに向いている（手のひらの法線がカメラの前方向の許容範囲内）
            let forward = SIMD3<Float>(0, 0, -1)
            let palmNormalLength = simd_length(palmNormal)
            let forwardLength = simd_length(forward)
            guard palmNormalLength > 0 && forwardLength > 0 else { return false }
            let dotProduct = simd_dot(palmNormal, forward)
            let angle = acos(max(-1, min(1, dotProduct / (palmNormalLength * forwardLength))))
            return abs(angle) < HandGestureType.angleTolerance
        }
    }
} 