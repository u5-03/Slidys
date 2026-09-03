//
//  SlideHighlightText.swift
//  SlidesCore
//
//  リストスライドのキーワード強調用のオプトイン部品。
//  Item(_:keywords:) で、キーワードを .strokeColor + 太字で強調した Item を作れる。
//  使ったスライドにだけ効くので、既存デッキのレイアウトには影響しない。
//

import SwiftUI
import SlideKit

public enum SlideTextHighlighter {
    /// キーワード強調(.strokeColor + 太字)を適用した AttributedString を返す。
    /// 強調は「1項目1箇所」ルールを想定し、各キーワードの最初の出現のみに適用する。
    public static func attributed(_ text: String, keywords: [String]) -> AttributedString {
        var attributed = AttributedString(text)
        for keyword in keywords where !keyword.isEmpty {
            if let range = attributed.range(of: keyword) {
                attributed[range].foregroundColor = .strokeColor
                attributed[range].inlinePresentationIntent = .stronglyEmphasized
            }
        }
        return attributed
    }
}

public extension Item {
    /// キーワード強調付きの Item。
    /// - Parameter keywords: `.strokeColor` + 太字で強調する語(各語の最初の出現のみ)
    init(
        _ text: String,
        keywords: [String],
        accessory: ItemAccessory? = .bullet
    ) {
        self.init(accessory: accessory) {
            Text(SlideTextHighlighter.attributed(text, keywords: keywords))
        }
    }
}
