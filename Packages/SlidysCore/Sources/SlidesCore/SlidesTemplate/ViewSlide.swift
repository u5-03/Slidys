//
//  ViewSlide.swift
//  SlidysCore
//
//  Created by Yugo Sugiyama on 2025/03/01.
//

import SwiftUI
import SlideKit

@Slide
public struct ViewSlide<Content: View>: View {
    let view: () -> Content

    public init(
        @ViewBuilder view: @escaping () -> Content
    ) {
        self.view = view
    }

    public var body: some View {
        GeometryReader { proxy in
            HStack {
                Spacer()
                VStack {
                    Spacer()
                    view()
                    Spacer()
                }
                Spacer()
            }
        }
    }
}

#Preview {
    ViewSlide {
        Text("ContentTex")
    }
}
