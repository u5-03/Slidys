//
//  DuelAppModel.swift
//  YugiohDuelDiskPackage
//
//  ImmersiveSpace の開閉状態などアプリ全体の状態を保持する Observable。
//  HandGesturePackage の AppModel と分離している。
//

import Foundation
import Observation

/// アプリ全体の状態を保持する Observable。
///
/// **MainActor 前提**: SwiftUI から参照するため、書き込みは MainActor 上のみで行うこと。
/// `@MainActor` を class に付けると SwiftUI EnvironmentKey の `static var defaultValue`
/// 要件と衝突するため、`@unchecked Sendable` で逃がした上で運用ルールで担保している。
/// 共有インスタンスは [[DuelSharedStore]] 経由でアクセスすること。
@Observable
public final class DuelAppModel: @unchecked Sendable {
    public let immersiveSpaceID = DuelImmersiveSpaceID.yugiohDuelDisk

    public enum ImmersiveSpaceState: Sendable {
        case closed
        case inTransition
        case open
    }

    public var immersiveSpaceState: ImmersiveSpaceState = .closed

    public init() {}

    public func updateImmersiveSpaceState(_ state: ImmersiveSpaceState) {
        immersiveSpaceState = state
    }
}
