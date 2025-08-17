//
//  HandTrackingComponent.swift
//  HandGesturePackage
//
//  Created by yugo.sugiyama on 2025/06/05.
//

import RealityKit
import Foundation

#if os(visionOS)
import ARKit
#endif

/// 手のトラッキング情報を保持するコンポーネント
public struct HandTrackingComponent: Component {
    /// 左手か右手かを示す
    public var chirality: HandAnchor.Chirality

    /// 各関節のエンティティを保持する辞書
    public var fingers: [HandSkeleton.JointName: Entity] = [:]

    /// 骨（関節間の接続）のエンティティを保持する辞書
    public var bones: [HandSkeleton.JointName: ModelEntity] = [:]

    public init(chirality: HandAnchor.Chirality) {
        self.chirality = chirality
    }
}