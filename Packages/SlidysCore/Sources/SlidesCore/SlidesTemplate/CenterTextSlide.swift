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

    public init(text: String, alignment: Alignment = .center) {
        self.text = text
        self.alignment = alignment
    }

    public var body: some View {
        Text(text)
            .font(.largeFont)
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
