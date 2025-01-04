//
//  StrokeAnimatableShapeCodeSlide.swift
//  ChibaSwiftSlide
//
//  Created by Yugo Sugiyama on 2024/09/08.
//

import SwiftUI
import SlideKit
import SlidesCore

let code = """
struct StrokeAnimatableShape<S: Shape> {
    var animationProgress: CGFloat = 0
    let shape: S
}

extension StrokeAnimatableShape: Shape {
    var animatableData: CGFloat {
        get { animationProgress }
        set { animationProgress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        return shape.path(in: rect)
            .trimmedPath(from: 0, to: animationProgress)
    }
} 
"""

@Slide
struct StrokeAnimatableShapeCodeSlide: View {
    var body: some View {
        HeaderSlide("実際のコード1") {
            Code(code,
                 colorTheme: .defaultDark,
                 fontSize: 40
            )
        }
    }
}

#Preview {
    SlidePreview {
        StrokeAnimatableShapeCodeSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}

