//
//  FlutterView.swift
//
//
//  Created by Yugo Sugiyama on 2024/11/10.
//

import SwiftUI
import SlidesCore

struct FlutterView: View {
    @Environment(\.router) var router
    @Environment(\.isSlideThumbnail) private var isSlideThumbnail
    let type: FlutterKaigiViewType

    var body: some View {
        if isSlideThumbnail {
            // スライド一覧 / PDF 書き出しでは Flutter を起動せずダミーを出す
            EmbeddedContentPlaceholder(title: "Flutter デモ", systemImage: "iphone.gen3")
        } else {
            flutterContent
        }
    }

    private var flutterContent: some View {
        router.build(viewType: type)
    }
}


