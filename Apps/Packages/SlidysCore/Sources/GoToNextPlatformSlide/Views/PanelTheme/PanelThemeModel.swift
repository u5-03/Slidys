//
//  PanelThemeModel.swift
//  SlidysCore
//
//  Created by yugo.sugiyama on 2025/02/21.
//

import SwiftUI

struct PanelThemeModel: Identifiable {
    let id = UUID()
    let title: String
    let backgroundColor: Color
    let descriptions: [String]
}

enum PanelData {
    static let panelThemeList: [PanelThemeModel] = [
        .init(
            title: "IDEについて",
            backgroundColor: .red,
            descriptions: [
                "XcodeとAndroidStudioとVSCodeの比較",
                "コード補完",
                "Preview, Simulator, Emulatorなどの表示確認方法"
            ]
        ),
        .init(
            title: "ライブラリ・パッケージの\n管理ツール・戦略について",
            backgroundColor: .blue,
            descriptions: [
                "Swift Package Manger, Gradle, pub package managerのツールの特徴",
                "使うライブラリのトレンド"
            ]
        ),
        .init(
            title: "非同期処理の仕方",
            backgroundColor: .yellow,
            descriptions: [
                "Swift Concurrency, Kotlin Coroutines, Future/Isolationの特徴など",
                "非同期処理の変遷・歴史"
            ]
        ),
        .init(
            title: "エコシステムとコミュニティ:\n学習リソースとサポート体制の違い",
            backgroundColor: .green,
            descriptions: [
                "チュートリアルやサンプルアプリなど",
                "コミュニティ・カンファレンス"
            ]
        ),
    ]
}
