//
//  Router.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/11/10.
//

import SwiftUI
import FlutterKaigiSlide

public struct Router: RouterProtocol {
    public init() {}

    /// 遷移先の画面を返すだけ, 画面遷移 はView側で行う
    public func build(viewType: FlutterViewType) -> AnyView {
        return AnyView(SlidysFlutter.FlutterView(type: viewType))
    }
}
