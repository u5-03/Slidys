//
//  FlutterKaigi2026Router.swift
//  SlidysFlutter
//
//  FlutterKaigi2026Slide のデモ画面(Flutter)を FlutterViewController として供給する。
//

import SwiftUI
import FlutterKaigi2026Slide

public struct FlutterKaigi2026Router: RouterProtocol {
    public init() {}

    /// 遷移先の画面を返すだけ, 画面遷移 はView側で行う
    public func build(viewType: FlutterKaigi2026ViewType) -> AnyView {
        return AnyView(SlidysFlutter.FlutterView(type: .flutterKaigi2026(type: viewType)))
    }
}
