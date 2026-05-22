//
//  DuelEnvironment.swift
//  YugiohDuelDiskPackage
//
//  SwiftUI の Environment で AppModel / SessionStore を引き回すためのキー定義。
//

import SwiftUI

// EnvironmentKey の defaultValue は `DuelSharedStore` の static let を参照することで、
// SamplePage Window 側と ImmersiveSpace 側で同一インスタンスを共有する。
// 「事実上のシングルトン」ではなく、明示的に DuelSharedStore に置いているため意図が読みやすい。
private struct DuelAppModelKey: EnvironmentKey {
    static let defaultValue: DuelAppModel = DuelSharedStore.appModel
}

private struct DuelSessionStoreKey: EnvironmentKey {
    static let defaultValue: DuelSessionStore = DuelSharedStore.session
}

public extension EnvironmentValues {
    var duelAppModel: DuelAppModel {
        get { self[DuelAppModelKey.self] }
        set { self[DuelAppModelKey.self] = newValue }
    }

    var duelSessionStore: DuelSessionStore {
        get { self[DuelSessionStoreKey.self] }
        set { self[DuelSessionStoreKey.self] = newValue }
    }
}
