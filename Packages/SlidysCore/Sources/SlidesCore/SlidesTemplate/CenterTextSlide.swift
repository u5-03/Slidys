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

    public init(text: String) {
        self.text = text
    }

    public var body: some View {
        Text(text)
            .font(.largeFont)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .foregroundStyle(.defaultForegroundColor)
            .background(.slideBackgroundColor)

    }
}

#Preview {
    SlidePreview {
        CenterTextSlide(text: "CenterText")
    }
}
