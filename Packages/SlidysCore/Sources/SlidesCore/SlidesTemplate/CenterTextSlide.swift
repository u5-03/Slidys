//
//  CenterTextSlide.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/10/27.
//

import SwiftUI
import SlideKit

@Slide
public struct CenterTextSlide: View {
    let text: String
    let alignment: Alignment
    let font: Font
    /// 多言語対応デッキ用: `text` をキーに、このバンドルの String Catalog から表示言語の文言を引く
    let localizationBundle: Bundle?
    /// スピーカーノート(発表者用の原稿。ノートWindowに表示される)
    public let script: String

    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    public init(
        text: String,
        alignment: Alignment = .center,
        font: Font = .largeFont,
        localizationBundle: Bundle? = nil,
        script: String = ""
    ) {
        self.text = text
        self.alignment = alignment
        self.font = font
        self.localizationBundle = localizationBundle
        self.script = script
    }

    private var displayText: String {
        guard let localizationBundle else { return text }
        return SlideLanguageStore.shared.localized(text, bundle: localizationBundle)
    }

    public var body: some View {
        Text(displayText)
            .lineSpacing(24)
            .font(font)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
            .foregroundStyle(.defaultForegroundColor)
            .background(.slideBackgroundColor)
    }
}

#Preview {
    SlidePreview {
        CenterTextSlide(text: "CenterText")
    }
}
