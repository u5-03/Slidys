//
//  QuizTitleSlide.swift
//  ChibaSwiftSlide
//
//  Created by Yugo Sugiyama on 2024/09/08.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct QuizTitleSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        ZStack {
            Image(.chiba)
                .resizable()
                .scaledToFit()
                .foregroundStyle(Color(.lightGray))
                .offset(.init(width: 80, height: 0))
                .blur(radius: 8)
                .padding(20)
            Text("千葉 シンボルクイズ！")
                .font(.extraLargeFont)
                .shadow(radius: 30, x: 20, y: 20)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundStyle(.strokeColor)
        }
        .background(.slideBackgroundColor)
    }
}

#Preview {
    SlidePreview {
        QuizTitleSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
