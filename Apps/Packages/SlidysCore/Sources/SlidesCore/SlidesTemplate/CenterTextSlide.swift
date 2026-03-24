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
    
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    public init(text: String, alignment: Alignment = .center, font: Font = .largeFont) {
        self.text = text
        self.alignment = alignment
        self.font = font
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
