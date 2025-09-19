//
//  HandGestureData.swift
//  HandGesturePackage
//
//  Created by yugo.sugiyama on 2025/06/05.
//

import ARKit
import simd
import Foundation

// MARK: - 両手ジェスチャーマッチング用のデータホルダー

public struct HandGestureData {
    // 左手の関節位置と向き
    var leftJointWorldPositions: [HandSkeleton.JointName: SIMD3<Float>] = [:]
    var leftPalmWorldPosition: SIMD3<Float> = .zero
    var leftPalmNormal: SIMD3<Float> = .zero
    var leftWristWorldPosition: SIMD3<Float> = .zero
    var leftForearmWorldPosition: SIMD3<Float> = .zero

    // 右手の関節位置と向き
    var rightJointWorldPositions: [HandSkeleton.JointName: SIMD3<Float>] = [:]
    var rightPalmWorldPosition: SIMD3<Float> = .zero
    var rightPalmNormal: SIMD3<Float> = .zero
    var rightWristWorldPosition: SIMD3<Float> = .zero
    var rightForearmWorldPosition: SIMD3<Float> = .zero

    public init(
        leftJointWorldPositions: [HandSkeleton.JointName: SIMD3<Float>] = [:],
        leftPalmWorldPosition: SIMD3<Float> = .zero,
        leftPalmNormal: SIMD3<Float> = .zero,
        leftWristWorldPosition: SIMD3<Float> = .zero,
        leftForearmWorldPosition: SIMD3<Float> = .zero,
        rightJointWorldPositions: [HandSkeleton.JointName: SIMD3<Float>] = [:],
        rightPalmWorldPosition: SIMD3<Float> = .zero,
        rightPalmNormal: SIMD3<Float> = .zero,
        rightWristWorldPosition: SIMD3<Float> = .zero,
        rightForearmWorldPosition: SIMD3<Float> = .zero
    ) {
        self.leftJointWorldPositions = leftJointWorldPositions
        self.leftPalmWorldPosition = leftPalmWorldPosition
        self.leftPalmNormal = leftPalmNormal
        self.leftWristWorldPosition = leftWristWorldPosition
        self.leftForearmWorldPosition = leftForearmWorldPosition
        self.rightJointWorldPositions = rightJointWorldPositions
        self.rightPalmWorldPosition = rightPalmWorldPosition
        self.rightPalmNormal = rightPalmNormal
        self.rightWristWorldPosition = rightWristWorldPosition
        self.rightForearmWorldPosition = rightForearmWorldPosition
    }
} 