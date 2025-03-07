//
//  ContentSlide.swift
//  SlidysCore
//
//  Created by Yugo Sugiyama on 2025/03/01.
//

import SwiftUI
import SlideKit

@Slide
public struct ContentSlide<Content: View>: View {
    let headerTitle: String
    let content: () -> Content

    public init(
        headerTitle: String,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.headerTitle = headerTitle
        self.content = content
    }

    public var body: some View {
        HeaderSlide(.init(stringLiteral: headerTitle)) {
            GeometryReader { proxy in
                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                        content()
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    ContentSlide(headerTitle: "CenterText") {
        Text("ContentTex")
    }
}
