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
    /// スピーカーノート(発表者用の原稿。ノートWindowに表示される)
    public let script: String

    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    public init(text: String, alignment: Alignment = .center, font: Font = .largeFont, script: String = "") {
        self.text = text
        self.alignment = alignment
        self.font = font
        self.script = script
    }

    public var body: some View {
        Text(text)
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
