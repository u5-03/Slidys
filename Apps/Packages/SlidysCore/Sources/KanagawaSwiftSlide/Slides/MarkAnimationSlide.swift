//
//  MarkAnimationSlide.swift
//  KanagawaSwiftSlide
//
//  Created by Yugo Sugiyama on 2024/11/02.
//


import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct MarkAnimationSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("こんなアニメーションも完全SwiftUIで作れる！") {
            HStack {
                Spacer()
                PathAnimationShapeView(
                    shape: MarkShape(),
                    lineWidth: 30,
                    lineColor: .white,
                    duration: .seconds(5),
                    isPaused: false
                )
                .aspectRatio(1, contentMode: .fit)
                Spacer()
            }
        }
    }
}

#Preview {
    SlidePreview {
        MarkAnimationSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
