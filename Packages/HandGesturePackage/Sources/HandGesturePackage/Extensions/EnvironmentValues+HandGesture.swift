//
//  EnvironmentValues+HandGesture.swift
//  HandGesturePackage
//
//  Created by Assistant on 2024/12/10.
//

import SwiftUI

// MARK: - GestureInfoStore

private struct GestureInfoStoreKey: EnvironmentKey {
    static let defaultValue = GestureInfoStore()
}

extension EnvironmentValues {
    /// ジェスチャー情報ストア
    public var gestureInfoStore: GestureInfoStore {
        get { self[GestureInfoStoreKey.self] }
        set { self[GestureInfoStoreKey.self] = newValue }
    }
}

// MARK: - AppModel

private struct AppModelKey: EnvironmentKey {
    static let defaultValue = AppModel()
}

extension EnvironmentValues {
    /// アプリケーションモデル
    public var appModel: AppModel {
        get { self[AppModelKey.self] }
        set { self[AppModelKey.self] = newValue }
    }
}