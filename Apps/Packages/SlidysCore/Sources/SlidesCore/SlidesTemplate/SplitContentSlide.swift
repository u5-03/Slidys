//
//  TitleSplitSlide.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/11/05.
//

import SwiftUI
import SlideKit

@Slide
public struct SplitContentSlide<Content1: View, Content2: View>: View {
    let leadingWidthRatio: CGFloat
    let leadingContent: Content1
    let trailingContent: Content2

    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    public init(
        leadingWidthRatio: CGFloat = 0.5,
        @ViewBuilder leadingContent: () -> Content1,
        @ViewBuilder trailingContent: () -> Content2
    ) {
        self.leadingWidthRatio = leadingWidthRatio
        self.leadingContent = leadingContent()
        self.trailingContent = trailingContent()
    }

    public var body: some View {
        GeometryReader { proxy  in
            HStack(spacing: 32) {
                leadingContent
                    .padding(.leading, 52)
                    .foregroundStyle(.defaultForegroundColor)
                    .frame(width: proxy.size.width * leadingWidthRatio, alignment: .leading)
                trailingContent
                    .padding(.trailing, 120)
                    .frame(width: proxy.size.width * (1 - leadingWidthRatio), alignment: .center)
            }
            .frame(maxHeight: .infinity)
            .padding(.horizontal, 32)
        }
        .background(.slideBackgroundColor)
    }
}

#Preview {
    SplitContentSlide(leadingWidthRatio: 0.65) {
        Color.red
    } trailingContent: {
        Color.blue
    }
}
