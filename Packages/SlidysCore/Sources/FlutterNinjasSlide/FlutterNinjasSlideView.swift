//
//  FlutterNinjasSlideView.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/11/10.
//

import SwiftUI
import SlideKit
import SlidesCore

public struct FlutterNinjasSlideView: SlideViewProtocol {
    let configuration = SlideConfiguration()
    let router: RouterProtocol

    public init(router: RouterProtocol) {
        self.router = router
    }

    public var body: some View {
        SlideBaseView(slideConfiguration: configuration)
            .environment(\.router, router)
    }
}
