//
//  Router.swift
//
//
//  Created by Yugo Sugiyama on 2024/11/10.
//

import SwiftUI

public enum FlutterViewType: String {
    case piano
    case circle
    case calendar
    case circleAnimation

    public var path: String {
        return "/\(rawValue)"
    }
}

// Ref: https://qiita.com/Soccerboy_Hamada/items/686e994c53736593659e
public protocol RouterProtocol {
    func build(viewType: FlutterViewType) -> AnyView
}

public struct RouterKey: EnvironmentKey {
    public static var defaultValue: RouterProtocol = DefaultRouter()
}

public extension EnvironmentValues {
    var router: RouterProtocol {
        get { self[RouterKey.self] }
        set { self[RouterKey.self] = newValue }
    }
}

struct DefaultRouter: RouterProtocol {
    /// 遷移先の画面を返すだけ, 画面遷移 はView側で行う
    func build(viewType: FlutterViewType) -> AnyView {
        return AnyView(EmptyView())
    }
}
