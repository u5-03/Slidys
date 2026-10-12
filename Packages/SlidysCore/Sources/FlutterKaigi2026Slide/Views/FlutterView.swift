//
//  FlutterView.swift
//  FlutterKaigi2026Slide
//

import SwiftUI
import SlidesCore

/// Router 経由でホストアプリ(SlidysFlutter)の FlutterViewController を埋め込む。
struct FlutterView: View {
    @Environment(\.router) var router
    @Environment(\.isSlideThumbnail) private var isSlideThumbnail
    let type: FlutterKaigi2026ViewType

    var body: some View {
        if isSlideThumbnail {
            // スライド一覧 / PDF 書き出しでは Flutter を起動せずダミーを出す
            EmbeddedContentPlaceholder(
                title: "Flutter デモ".loc,
                systemImage: "iphone.gen3",
                caption: "発表時はここに実際の画面が表示されます".loc
            )
        } else {
            flutterContent
        }
    }

    private var flutterContent: some View {
        router.build(viewType: type)
            // 連続のページで表示しようとすると、同じFlutterのWidgetになってしまうため、IDを指定
            .id(type.path)
    }
}
