//
//  HandGestureScene.swift
//  HandGesturePackage
//
//  Created by yugo.sugiyama on 2025/06/05.
//

import SwiftUI

/// ハンドジェスチャーアプリのメインシーン
public struct HandGestureScene: Scene {
    @State private var appModel = AppModel()
    @State private var gestureInfoStore = GestureInfoStore()

    public init() {}

    public var body: some Scene {
        // メインウィンドウ（初回起動時のWelcomeView）
        WindowGroup(id: "WelcomeWindow") {
            StartDemoView()
                .environment(\.appModel, appModel)
                .environment(\.gestureInfoStore, gestureInfoStore)
        }
        .windowStyle(.plain)
        .defaultSize(width: 1000, height: 600)

        // ジェスチャー情報ウィンドウ
        WindowGroup(id: "GestureInfoWindow") {
            GestureInfoView()
                .environment(\.appModel, appModel)
                .environment(\.gestureInfoStore, gestureInfoStore)
        }
        .windowStyle(.plain)
        .defaultSize(width: 500, height: 1000)
        .windowResizability(.contentSize)

        // ImmersiveSpace（ハンドジェスチャー体験）
        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            HandGestureImmersiveView()
                .environment(\.appModel, appModel)
                .environment(\.gestureInfoStore, gestureInfoStore)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
