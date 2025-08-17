//
//  HandSkeletonJointName+Extensions.swift
//  HandGesturePackage
//
//  Created by yugo.sugiyama on 2025/06/05.
//

import ARKit
import Foundation

// MARK: - JointNameのヘルパー拡張（中間関節、親/子関節用）

@MainActor
public extension HandSkeleton.JointName {
    static var allFingertipJoints: [HandSkeleton.JointName] {
        return [.thumbTip, .indexFingerTip, .middleFingerTip, .ringFingerTip, .littleFingerTip]
    }

    var baseJoint: HandSkeleton.JointName {
        switch self {
        case .thumbTip: return .thumbKnuckle
        case .indexFingerTip: return .indexFingerMetacarpal
        case .middleFingerTip: return .middleFingerMetacarpal
        case .ringFingerTip: return .ringFingerMetacarpal
        case .littleFingerTip: return .littleFingerMetacarpal
        default: return self
        }
    }

    static var allIntermediateJoints: [HandSkeleton.JointName] {
        return [
            // 親指の中間関節
            .thumbIntermediateBase, .thumbIntermediateTip,
            // 人差し指の中間関節
            .indexFingerKnuckle, .indexFingerIntermediateBase, .indexFingerIntermediateTip,
            // 中指の中間関節
            .middleFingerKnuckle, .middleFingerIntermediateBase, .middleFingerIntermediateTip,
            // 薬指の中間関節
            .ringFingerKnuckle, .ringFingerIntermediateBase, .ringFingerIntermediateTip,
            // 小指の中間関節
            .littleFingerKnuckle, .littleFingerIntermediateBase, .littleFingerIntermediateTip
        ]
    }

    var isIntermediateJoint: Bool {
        return HandSkeleton.JointName.allIntermediateJoints.contains(self)
    }

    var parentJoint: HandSkeleton.JointName {
        switch self {
            // 親指
        case .thumbIntermediateTip: return .thumbIntermediateBase
        case .thumbIntermediateBase: return .thumbKnuckle
            // 人差し指
        case .indexFingerIntermediateTip: return .indexFingerIntermediateBase
        case .indexFingerIntermediateBase: return .indexFingerKnuckle
        case .indexFingerKnuckle: return .indexFingerMetacarpal
            // 中指
        case .middleFingerIntermediateTip: return .middleFingerIntermediateBase
        case .middleFingerIntermediateBase: return .middleFingerKnuckle
        case .middleFingerKnuckle: return .middleFingerMetacarpal
            // 薬指
        case .ringFingerIntermediateTip: return .ringFingerIntermediateBase
        case .ringFingerIntermediateBase: return .ringFingerKnuckle
        case .ringFingerKnuckle: return .ringFingerMetacarpal
            // 小指
        case .littleFingerIntermediateTip: return .littleFingerIntermediateBase
        case .littleFingerIntermediateBase: return .littleFingerKnuckle
        case .littleFingerKnuckle: return .littleFingerMetacarpal
        default: return self
        }
    }

    var childJoint: HandSkeleton.JointName {
        switch self {
            // 親指
        case .thumbKnuckle: return .thumbIntermediateBase
        case .thumbIntermediateBase: return .thumbIntermediateTip
        case .thumbIntermediateTip: return .thumbTip
            // 人差し指
        case .indexFingerKnuckle: return .indexFingerIntermediateBase
        case .indexFingerIntermediateBase: return .indexFingerIntermediateTip
        case .indexFingerIntermediateTip: return .indexFingerTip
            // 中指
        case .middleFingerKnuckle: return .middleFingerIntermediateBase
        case .middleFingerIntermediateBase: return .middleFingerIntermediateTip
        case .middleFingerIntermediateTip: return .middleFingerTip
            // 薬指
        case .ringFingerKnuckle: return .ringFingerIntermediateBase
        case .ringFingerIntermediateBase: return .ringFingerIntermediateTip
        case .ringFingerIntermediateTip: return .ringFingerTip
            // 小指
        case .littleFingerKnuckle: return .littleFingerIntermediateBase
        case .littleFingerIntermediateBase: return .littleFingerIntermediateTip
        case .littleFingerIntermediateTip: return .littleFingerTip
        default: return self
        }
    }
} 