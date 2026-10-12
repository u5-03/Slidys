//
//  FlutterKaigiSlideView.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/11/10.
//

import SwiftUI
import SlideKit
import SlidesCore

public struct FlutterKaigiSlideView: SlideViewProtocol {
    let configuration = SlideConfiguration()
    let router: RouterProtocol

    public init(router: RouterProtocol) {
        self.router = router
    }

    public var body: some View {
        SlideBaseView(slideConfiguration: configuration)
            .environment(\.router, router)
            // 外部ディスプレイ(presentation モード)は別 Window に描くので、そちらにも Router を渡す
            .environment(\.externalDisplaySlideDecorator) { slide in
                AnyView(slide.environment(\.router, router))
            }
    }
}
