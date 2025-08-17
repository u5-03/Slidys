//
//  AppModel.swift
//  HandGesturePackage
//
//  Created by yugo.sugiyama on 2025/06/05.
//

import Foundation
import simd
import Observation

/// アプリケーション全体の状態を管理するモデル
@Observable
public final class AppModel: @unchecked Sendable {
    
    // MARK: - ImmersiveSpace管理

    /// ImmersiveSpaceのID
    public let immersiveSpaceID = "HandGestureImmersiveSpace"

    /// ImmersiveSpaceの状態
    public enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }

    /// 現在のImmersiveSpaceの状態
    public var immersiveSpaceState = ImmersiveSpaceState.closed

    // MARK: - ハンドトラッキング状態

    /// 左手がピンチしているかどうか
    public var isPinchingLeftHand = false

    /// 右手がピンチしているかどうか
    public var isPinchingRightHand = false

    /// 左手のピンチ位置（ワールド座標）
    public var leftPinchPosition: SIMD3<Float> = .zero

    /// 右手のピンチ位置（ワールド座標）
    public var rightPinchPosition: SIMD3<Float> = .zero

    public init() {}

    // MARK: - Public Methods

    /// ピンチ状態をリセット
    public func resetPinchStates() {
        isPinchingLeftHand = false
        isPinchingRightHand = false
        leftPinchPosition = .zero
        rightPinchPosition = .zero
    }

    /// ImmersiveSpaceの状態を更新
    public func updateImmersiveSpaceState(_ state: ImmersiveSpaceState) {
        immersiveSpaceState = state
    }
}
