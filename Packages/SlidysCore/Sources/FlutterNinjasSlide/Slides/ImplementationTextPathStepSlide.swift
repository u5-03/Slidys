//
//  ImplementationTextPathStepSlide.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/11/06.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct ImplementationTextPathStepSlide: View {
    var body: some View {
        HeaderSlide("Text drawing animation") {
            Item("Get PathMetric (subpath information) from Path object using computeMetrics()", accessory: .number(1))
            Item("Use PathMetric's getTangentForOffset() to get coordinates (position) and angle of direction at any position (offset) on the Path", accessory: .number(2))
            Item("The offset value can be calculated by multiplying the total length of the Path by the progress value (0.0-1.0) to dynamically determine the position according to the animation progress", accessory: .number(3))
            Item("Place widgets to be displayed at the obtained coordinates using Positioned etc.", accessory: .number(4))
        }
    }
}

#Preview {
    SlidePreview {
        ImplementationTextPathStepSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
