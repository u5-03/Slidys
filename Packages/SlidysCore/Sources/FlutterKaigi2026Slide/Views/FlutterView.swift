//
//  FlutterView.swift
//  FlutterKaigi2026Slide
//

import SwiftUI

/// Router 経由でホストアプリ(SlidysFlutter)の FlutterViewController を埋め込む。
struct FlutterView: View {
    @Environment(\.router) var router
    let type: FlutterKaigi2026ViewType

    var body: some View {
        router.build(viewType: type)
            // 連続のページで表示しようとすると、同じFlutterのWidgetになってしまうため、IDを指定
            .id(type.path)
    }
}
