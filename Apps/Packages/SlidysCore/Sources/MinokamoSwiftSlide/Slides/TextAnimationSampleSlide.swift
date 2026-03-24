//
//  TextAnimationSampleSlide.swift
//  SlidysCore
//
//  Created by Yugo Sugiyama on 2025/01/05.
//


import SwiftUI
import SlideKit
import SlidesCore
import SymbolKit

@Slide
struct TextAnimationSampleSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    @Phase var phase: SlidePhase
    enum SlidePhase: Int, PhasedState {
        case initial
        case second
    }

    var body: some View {
        HeaderSlide("アルファベットをアニメーションで表示") {

            VStack(alignment: .leading, spacing: 0) {
                Text("システムフォント")
                    .foregroundStyle(.defaultForegroundColor)
                    .font(.mediumFont)
                StrokeAnimationShapeView(
                    shape: TextPathShape(
                        "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
                        font: .systemFont(ofSize: 100)
                    ),
                    lineWidth: 3,
                    lineColor: .white,
                    duration: .seconds(3),
                    isPaused: false,
                    shapeAspectRatio: 8
                )
                if phase.isAfter(.second) {
                    Text("SinglePathのフォント")
                        .foregroundStyle(.defaultForegroundColor)
                        .font(.mediumFont)

                    StrokeAnimationShapeView(
                        shape: TextPathShape(
                            "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
                            font: .singlePathLineFont(size: 100)
                        ),
                        lineWidth: 10,
                        lineColor: .white,
                        duration: .seconds(3),
                        isPaused: false,
                        shapeAspectRatio: 8
                    )
                }
            }
        }
    }
}

#Preview {
    SlidePreview {
        TextAnimationSampleSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
