//
//  ImplementationStep3Slide.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/11/06.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct ImplementationStep3Slide: View {
    var body: some View {
        HeaderSlide("Step 3: Make the Path display partially based on progress") {
            Item("Get an array of PathMetric from the Path using computeMetrics()", accessory: .number(1)) {
                Item("PathMetric provides length, tangent, and segment information for a path.", accessory: .number(1))
            }
            Item("Use PathMetric's extractPath(0, totalLength * progress) to generate partial paths according to the progress rate (0.0~1.0)", accessory: .number(2))
            Item("Combine those Paths into a single Path using addPath()", accessory: .number(3))
            Item("Draw the path with canvas.drawPath in the CustomPainter", accessory: .number(4))
        }
    }
}

#Preview {
    SlidePreview {
        ImplementationStep3Slide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
