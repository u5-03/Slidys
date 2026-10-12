//
//  Localization.swift
//  FlutterKaigi2026Slide
//
//  このデッキの多言語対応(日本語 / 英語)。
//  文言は Localizable.xcstrings(String Catalog)にあり、キーは日本語の文言そのもの。
//  発表中にメニューから言語を切り替えられるよう、文言は描画のたびに SlideLanguageStore の
//  表示言語で引く(OS の言語設定だけに従う `String(localized:)` は使わない)。
//  スピーカーノート(script)は発表者が読むものなので、日本語のまま。
//

import SlideKit
import SlidesCore
import SwiftUI

extension String {
    /// このデッキの String Catalog から、いまの表示言語の文言を引く(訳が無ければ日本語のまま)
    var loc: String {
        SlideLanguageStore.shared.localized(self, bundle: .module)
    }
}

extension HeaderSlide {
    /// 見出しを String Catalog のキー(日本語の文言)で指定する
    init(loc key: String, @ViewBuilder content: @escaping () -> some View) {
        let header = key.loc
        self.init(header: { Text(verbatim: header) }, content: content)
    }
}

extension Item {
    /// 本文と強調語を String Catalog のキー(日本語の文言)で指定する。
    /// 強調語は、訳した本文の中にそのまま出てくる語になるよう訳しておくこと。
    init(loc key: String, keywords: [String] = [], accessory: ItemAccessory? = .bullet) {
        self.init(key.loc, keywords: keywords.map(\.loc), accessory: accessory)
    }
}
