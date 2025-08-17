//
//  HandGestureImmersiveView.swift
//  HandGesturePackage
//
//  Created by yugo.sugiyama on 2025/06/05.
//

import SwiftUI
import RealityKit
import HandGestureKit

/// ハンドジェスチャー体験用のImmersiveView
public struct HandGestureImmersiveView: View {
    @Environment(\.appModel) private var appModel
    @Environment(\.gestureInfoStore) private var gestureStore
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow

    public init() {}

    public var body: some View {
        // メインのハンドジェスチャー検出用RealityView
        HandGestureRealityView()
            .ignoresSafeArea()
            .onAppear {
                appModel.updateImmersiveSpaceState(.open)
                // ジェスチャー情報ウィンドウを開く
                openWindow(id: "GestureInfoWindow")
                HandGestureLogger.logUI("ImmersiveView appeared - Hand tracking started")
            }
            .onDisappear {
                appModel.updateImmersiveSpaceState(.closed)
                appModel.resetPinchStates()
                gestureStore.resetAll()
                // ジェスチャー情報ウィンドウを閉じる
                dismissWindow(id: "GestureInfoWindow")
                HandGestureLogger.logUI("ImmersiveView disappeared - Hand tracking stopped")
            }
    }
}

#Preview(immersionStyle: .mixed) {
    HandGestureImmersiveView()
        .environment(\.appModel, AppModel())
        .environment(\.gestureInfoStore, GestureInfoStore())
}
