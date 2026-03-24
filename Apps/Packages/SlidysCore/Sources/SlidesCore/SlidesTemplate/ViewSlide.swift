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

    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

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
        .foregroundStyle(.defaultForegroundColor)
        .background(.slideBackgroundColor)
    }
}

#Preview {
    SlidePreview {
        ViewSlide {
            Text("デモ")
                .font(.extraLargeFont)
                .padding()
            Text("ジェスチャーや手話の検知")
                .font(.largeFont)
                .padding()
            Text("冒頭の手話の答え合わせ")
                .font(.largeFont)
                .padding()
        }
    }
}
