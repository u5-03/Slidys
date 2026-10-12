//
//  Router.swift
//  FlutterKaigi2026Slide
//
//  FlutterKaigi 2026 LT で埋め込む Flutter 側デモ画面の種類。
//  flutter_slide/lib/main.dart の PageType(routeName = "/<name>")と名前を揃える。
//

import SwiftUI

public enum FlutterKaigi2026ViewType: String {
    /// フローティングボタン → Debug Menu → Issue 起票までの一連のデモ
    case feedbackDemo
    /// 画面上の Widget を Bounding Box で囲んで選ぶ ElementPicker のデモ
    case elementPicker
    /// 静止画リングバッファ → デバイスで動画化する画面リプレイのデモ
    case screenReplay
    /// Element ツリーを歩いて Widget 階層をテキスト化するデモ
    case widgetTree
    /// 「最大の差分: ログは自分で溜める」のページを丸ごと Flutter で描き、わざと入れた誤字を起票するデモ
    case logSlide

    public var path: String {
        return "/\(rawValue)"
    }
}

// Ref: https://qiita.com/Soccerboy_Hamada/items/686e994c53736593659e
public protocol RouterProtocol {
    func build(viewType: FlutterKaigi2026ViewType) -> AnyView
}

public struct RouterKey: EnvironmentKey {
    public static var defaultValue: RouterProtocol = DefaultRouter()
}

extension EnvironmentValues {
    public var router: RouterProtocol {
        get { self[RouterKey.self] }
        set { self[RouterKey.self] = newValue }
    }
}

struct DefaultRouter: RouterProtocol {
    /// 遷移先の画面を返すだけ, 画面遷移 はView側で行う
    func build(viewType: FlutterKaigi2026ViewType) -> AnyView {
        return AnyView(EmptyView())
    }
}
