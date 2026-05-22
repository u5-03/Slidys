//
//  YugiohDuelDiskScene.swift
//  YugiohDuelDiskPackage
//
//  デュエルディスク体験用の ImmersiveSpace を公開する Scene。
//  Window は SlidysCore 側の SamplePageType から開かれる前提なので、
//  ここでは ImmersiveSpace のみを生やす。
//

#if os(visionOS)
import SwiftUI

public struct YugiohDuelDiskScene: Scene {
    public init() {}

    public var body: some Scene {
        // ID 文字列を直接参照することで Scene 初期化で MainActor 隔離 type を踏まない。
        ImmersiveSpace(id: DuelImmersiveSpaceID.yugiohDuelDisk) {
            YugiohDuelDiskImmersiveView()
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
#endif
