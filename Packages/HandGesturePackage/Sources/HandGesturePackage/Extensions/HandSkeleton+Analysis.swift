//
//  HandSkeleton+Analysis.swift
//  HandGesturePackage
//
//  Created by yugo.sugiyama on 2025/06/05.
//

import RealityKit
import simd
import Foundation
import HandGestureKit

#if os(visionOS)
import ARKit
#endif

// MARK: - HandSkeleton Extensions

extension HandSkeleton {

    /// デフォルトの許容誤差（5%）
    static let defaultTolerance: Float = 0.05

    // MARK: - 手全体の分析

    /// 手と腕がまっすぐになっているかを判定
    func isArmStraight(tolerance: Float = defaultTolerance) -> Bool {
        let forearmJoint = joint(.forearmArm)
        let wristJoint = joint(.wrist)
        let middleMetacarpalJoint = joint(.middleFingerMetacarpal)

        return forearmJoint.isAlignedWith(wristJoint, and: middleMetacarpalJoint, tolerance: tolerance)
    }

    /// 手のひらの法線ベクトルを取得
    var palmNormal: SIMD3<Float> {
        let wristJoint = joint(.wrist)
        let indexMetacarpalJoint = joint(.indexFingerMetacarpal)
        let middleMetacarpalJoint = joint(.middleFingerMetacarpal)

        return wristJoint.calculateNormal(with: indexMetacarpalJoint, and: middleMetacarpalJoint)
    }

    /// 手のひらの向いている方向を判定
    func getPalmDirection(tolerance: Float = defaultTolerance) -> PalmDirection {
        return palmNormal.palmDirection(tolerance: tolerance)
    }

    /// 手のひらが奥を向いているかを判定
    func isPalmFacingAway(tolerance: Float = defaultTolerance) -> Bool {
        return palmNormal.isFacing(.backward, tolerance: tolerance)
    }

    /// 手のひらが手前を向いているかを判定
    func isPalmFacingToward(tolerance: Float = defaultTolerance) -> Bool {
        return palmNormal.isFacing(.forward, tolerance: tolerance)
    }

    /// 握りこぶしを作っているかを判定
    func isFist(tolerance: Float = defaultTolerance) -> Bool {
        return [FingerType.index, .middle, .ring, .little].allSatisfy { fingerType in
            isFingerBent(fingerType, tolerance: tolerance)
        }
    }

    /// ピースサイン（Vサイン）を作っているかを判定
    func isPeaceSign(tolerance: Float = defaultTolerance) -> Bool {
        // 人差し指と中指がまっすぐ
        guard isFingerStraight(.index, tolerance: tolerance) &&
              isFingerStraight(.middle, tolerance: tolerance) else {
            return false
        }

        // 薬指と小指が曲がっている
        guard isFingerBent(.ring, tolerance: tolerance) &&
              isFingerBent(.little, tolerance: tolerance) else {
            return false
        }

        // 親指の状態は自由（曲がっていても伸びていても良い）

        // 人差し指と中指が適度に開いているかを確認
        let indexTip = getFingerTipPosition(.index)
        let middleTip = getFingerTipPosition(.middle)
        let distance = simd_distance(indexTip, middleTip)

        // 指先間の距離が適度に開いている（2-5cm程度）
        let minDistance: Float = 0.02 // 2cm
        let maxDistance: Float = 0.05 // 5cm

        return distance >= minDistance && distance <= maxDistance
    }

    /// OKサインを作っているかを判定
    func isOKSign(tolerance: Float = defaultTolerance) -> Bool {
        // 親指と人差し指の先端が近い位置にある
        let thumbTip = getFingerTipPosition(.thumb)
        let indexTip = getFingerTipPosition(.index)
        let distance = simd_distance(thumbTip, indexTip)

        // 指先間の距離が1cm以下
        let maxDistance: Float = 0.01
        guard distance <= maxDistance else { return false }

        // 中指、薬指、小指がまっすぐ
        return isFingerStraight(.middle, tolerance: tolerance) &&
               isFingerStraight(.ring, tolerance: tolerance) &&
               isFingerStraight(.little, tolerance: tolerance)
    }

    /// 指を1本だけ立てているかを判定
    func isPointingFinger(_ targetFinger: FingerType, tolerance: Float = defaultTolerance) -> Bool {
        let allFingers: [FingerType] = [.thumb, .index, .middle, .ring, .little]

        for finger in allFingers {
            if finger == targetFinger {
                // 対象の指はまっすぐ
                if !isFingerStraight(finger, tolerance: tolerance) {
                    return false
                }
            } else {
                // その他の指は曲がっている
                if !isFingerBent(finger, tolerance: tolerance) {
                    return false
                }
            }
        }

        return true
    }

    /// 人差し指で指差しをしているかを判定
    func isPointing(tolerance: Float = defaultTolerance) -> Bool {
        return isPointingFinger(.index, tolerance: tolerance)
    }

    /// サムズアップ（親指立て）を作っているかを判定
    func isThumbsUp(tolerance: Float = defaultTolerance) -> Bool {
        return isPointingFinger(.thumb, tolerance: tolerance)
    }

    // MARK: - 指の分析

    /// 指定した指がまっすぐかを判定
    func isFingerStraight(_ finger: FingerType, tolerance: Float = defaultTolerance) -> Bool {
        let joints = getFingerJoints(for: finger)
        guard joints.count >= 3 else { return false }

        for i in 0..<(joints.count - 2) {
            let joint1 = joint(joints[i])
            let joint2 = joint(joints[i + 1])
            let joint3 = joint(joints[i + 2])

            if !joint1.isAlignedWith(joint2, and: joint3, tolerance: tolerance) {
                return false
            }
        }
        return true
    }

    /// 指定した指が曲がっているかを判定
    func isFingerBent(_ finger: FingerType, tolerance: Float = defaultTolerance) -> Bool {
        return !isFingerStraight(finger, tolerance: tolerance)
    }

    /// すべての指がまっすぐかを判定
    func areAllFingersStraight(tolerance: Float = defaultTolerance) -> Bool {
        let fingers: [FingerType] = [.thumb, .index, .middle, .ring, .little]
        return fingers.allSatisfy { isFingerStraight($0, tolerance: tolerance) }
    }

    /// 指定した関節が指定された角度範囲で曲がっているかを判定
    func isJointBent(_ jointName: JointName, minAngle: Float, maxAngle: Float, tolerance: Float = defaultTolerance) -> Bool {
        guard let parentJointName = getParentJoint(for: jointName),
              let childJointName = getChildJoint(for: jointName) else {
            return false
        }

        let parentJoint = joint(parentJointName)
        let currentJoint = joint(jointName)
        let childJoint = joint(childJointName)

        return currentJoint.isBent(
            between: minAngle,
            and: maxAngle,
            relativeTo: parentJoint,
            and: childJoint,
            tolerance: tolerance
        )
    }

    /// 指先の位置を取得
    func getFingerTipPosition(_ finger: FingerType) -> SIMD3<Float> {
        let tipJointName = getFingerTipJoint(for: finger)
        return joint(tipJointName).position
    }

    /// 指の基部の位置を取得
    func getFingerBasePosition(_ finger: FingerType) -> SIMD3<Float> {
        let joints = getFingerJoints(for: finger)
        return joint(joints.first!).position
    }

    /// 指の長さを計算
    func getFingerLength(_ finger: FingerType) -> Float {
        let basePosition = getFingerBasePosition(finger)
        let tipPosition = getFingerTipPosition(finger)
        return simd_distance(basePosition, tipPosition)
    }

    /// 指の方向ベクトルを取得
    func getFingerDirection(_ finger: FingerType) -> SIMD3<Float> {
        let basePosition = getFingerBasePosition(finger)
        let tipPosition = getFingerTipPosition(finger)
        return simd_normalize(tipPosition - basePosition)
    }
}

// MARK: - Joint Extensions

extension HandSkeleton.Joint {

    /// 位置をSIMD3として取得
    var position: SIMD3<Float> {
        let pos = anchorFromJointTransform.columns.3
        return SIMD3<Float>(pos.x, pos.y, pos.z)
    }

    /// 他の2つの関節と直線状に並んでいるかを判定
    func isAlignedWith(_ joint2: HandSkeleton.Joint, and joint3: HandSkeleton.Joint, tolerance: Float) -> Bool {
        let pos1 = self.position
        let pos2 = joint2.position
        let pos3 = joint3.position

        let vec1 = simd_normalize(pos2 - pos1)
        let vec2 = simd_normalize(pos3 - pos2)

        let dotProduct = simd_dot(vec1, vec2)
        let angle = acos(max(-1, min(1, dotProduct)))
        let angleInDegrees = angle * 180.0 / Float.pi

        let toleranceInDegrees = tolerance * 180.0 / Float.pi * 100

        return abs(angleInDegrees) <= toleranceInDegrees || abs(180 - angleInDegrees) <= toleranceInDegrees
    }

    /// 3つの関節で法線ベクトルを計算
    func calculateNormal(with joint2: HandSkeleton.Joint, and joint3: HandSkeleton.Joint) -> SIMD3<Float> {
        let pos1 = self.position
        let pos2 = joint2.position
        let pos3 = joint3.position

        let vec1 = pos2 - pos1
        let vec2 = pos3 - pos1

        return simd_normalize(simd_cross(vec1, vec2))
    }

    /// 指定された角度範囲で曲がっているかを判定
    func isBent(between minAngle: Float, and maxAngle: Float, relativeTo parentJoint: HandSkeleton.Joint, and childJoint: HandSkeleton.Joint, tolerance: Float) -> Bool {
        let parentPos = parentJoint.position
        let currentPos = self.position
        let childPos = childJoint.position

        let vec1 = simd_normalize(currentPos - parentPos)
        let vec2 = simd_normalize(childPos - currentPos)

        let dotProduct = simd_dot(vec1, vec2)
        let angle = acos(max(-1, min(1, dotProduct)))
        let angleInDegrees = angle * 180.0 / Float.pi

        let toleranceInDegrees = tolerance * (maxAngle - minAngle)

        return angleInDegrees >= (minAngle - toleranceInDegrees) && angleInDegrees <= (maxAngle + toleranceInDegrees)
    }
}

// MARK: - SIMD3 Extensions

extension SIMD3<Float> {

    /// 指定された方向を向いているかを判定
    func isFacing(_ direction: PalmDirection, tolerance: Float) -> Bool {
        let targetDirection = direction.vector
        let dotProduct = simd_dot(self, targetDirection)
        let toleranceValue = tolerance * 2.0

        return dotProduct >= (1.0 - toleranceValue)
    }

    /// 手のひらの向いている方向を判定
    func palmDirection(tolerance: Float) -> PalmDirection {
        let toleranceValue = tolerance * 2.0

        let directions: [PalmDirection] = [.up, .down, .right, .left, .forward, .backward]

        var maxDot: Float = -2.0
        var result: PalmDirection = .up

        for direction in directions {
            let dotProduct = simd_dot(self, direction.vector)
            if dotProduct > maxDot && dotProduct >= (1.0 - toleranceValue) {
                maxDot = dotProduct
                result = direction
            }
        }

        return result
    }
}

// MARK: - Helper Types and Methods

extension HandSkeleton {

    /// 指定した指の関節一覧を取得
    private func getFingerJoints(for finger: FingerType) -> [JointName] {
        switch finger {
        case .thumb:
            return [.thumbKnuckle, .thumbIntermediateBase, .thumbIntermediateTip, .thumbTip]
        case .index:
            return [.indexFingerMetacarpal, .indexFingerKnuckle, .indexFingerIntermediateBase, .indexFingerIntermediateTip, .indexFingerTip]
        case .middle:
            return [.middleFingerMetacarpal, .middleFingerKnuckle, .middleFingerIntermediateBase, .middleFingerIntermediateTip, .middleFingerTip]
        case .ring:
            return [.ringFingerMetacarpal, .ringFingerKnuckle, .ringFingerIntermediateBase, .ringFingerIntermediateTip, .ringFingerTip]
        case .little:
            return [.littleFingerMetacarpal, .littleFingerKnuckle, .littleFingerIntermediateBase, .littleFingerIntermediateTip, .littleFingerTip]
        }
    }

    /// 指定した指の先端関節を取得
    private func getFingerTipJoint(for finger: FingerType) -> JointName {
        switch finger {
        case .thumb: return .thumbTip
        case .index: return .indexFingerTip
        case .middle: return .middleFingerTip
        case .ring: return .ringFingerTip
        case .little: return .littleFingerTip
        }
    }

    /// 指定された関節の親関節を取得
    private func getParentJoint(for joint: JointName) -> JointName? {
        switch joint {
        // 親指
        case .thumbIntermediateBase: return .thumbKnuckle
        case .thumbIntermediateTip: return .thumbIntermediateBase
        case .thumbTip: return .thumbIntermediateTip

        // 人差し指
        case .indexFingerKnuckle: return .indexFingerMetacarpal
        case .indexFingerIntermediateBase: return .indexFingerKnuckle
        case .indexFingerIntermediateTip: return .indexFingerIntermediateBase
        case .indexFingerTip: return .indexFingerIntermediateTip

        // 中指
        case .middleFingerKnuckle: return .middleFingerMetacarpal
        case .middleFingerIntermediateBase: return .middleFingerKnuckle
        case .middleFingerIntermediateTip: return .middleFingerIntermediateBase
        case .middleFingerTip: return .middleFingerIntermediateTip

        // 薬指
        case .ringFingerKnuckle: return .ringFingerMetacarpal
        case .ringFingerIntermediateBase: return .ringFingerKnuckle
        case .ringFingerIntermediateTip: return .ringFingerIntermediateBase
        case .ringFingerTip: return .ringFingerIntermediateTip

        // 小指
        case .littleFingerKnuckle: return .littleFingerMetacarpal
        case .littleFingerIntermediateBase: return .littleFingerKnuckle
        case .littleFingerIntermediateTip: return .littleFingerIntermediateBase
        case .littleFingerTip: return .littleFingerIntermediateTip

        // 手首と前腕
        case .wrist: return .forearmWrist
        case .forearmWrist: return .forearmArm

        default: return nil
        }
    }

    /// 指定された関節の子関節を取得
    private func getChildJoint(for joint: JointName) -> JointName? {
        switch joint {
        // 親指
        case .thumbKnuckle: return .thumbIntermediateBase
        case .thumbIntermediateBase: return .thumbIntermediateTip
        case .thumbIntermediateTip: return .thumbTip

        // 人差し指
        case .indexFingerMetacarpal: return .indexFingerKnuckle
        case .indexFingerKnuckle: return .indexFingerIntermediateBase
        case .indexFingerIntermediateBase: return .indexFingerIntermediateTip
        case .indexFingerIntermediateTip: return .indexFingerTip

        // 中指
        case .middleFingerMetacarpal: return .middleFingerKnuckle
        case .middleFingerKnuckle: return .middleFingerIntermediateBase
        case .middleFingerIntermediateBase: return .middleFingerIntermediateTip
        case .middleFingerIntermediateTip: return .middleFingerTip

        // 薬指
        case .ringFingerMetacarpal: return .ringFingerKnuckle
        case .ringFingerKnuckle: return .ringFingerIntermediateBase
        case .ringFingerIntermediateBase: return .ringFingerIntermediateTip
        case .ringFingerIntermediateTip: return .ringFingerTip

        // 小指
        case .littleFingerMetacarpal: return .littleFingerKnuckle
        case .littleFingerKnuckle: return .littleFingerIntermediateBase
        case .littleFingerIntermediateBase: return .littleFingerIntermediateTip
        case .littleFingerIntermediateTip: return .littleFingerTip

        // 手首と前腕
        case .forearmArm: return .forearmWrist
        case .forearmWrist: return .wrist

        default: return nil
        }
    }
}
