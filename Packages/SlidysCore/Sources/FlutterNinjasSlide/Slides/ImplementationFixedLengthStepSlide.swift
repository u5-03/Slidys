//
//  ImplementationFixedLengthStepSlide.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/11/06.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct ImplementationFixedLengthStepSlide: View {
    var body: some View {
        HeaderSlide("Animation with fixed Path length") {
            Item("Get the total length of the Path with PathMetric, and calculate the display range from the Path length and progress rate", accessory: .number(1))
            Item("Process PathMetrics in a loop, calculating each display range", accessory: .number(2)) {
                Item("Within this display range, only addPath for Paths included in the overall display range", accessory: .number(1))
                Item("Do not addPath for Paths outside the range", accessory: .number(2))
            }
            Item("Combine the extracted partial Paths and execute the animation", accessory: .number(3))
        }
    }
}

#Preview {
    SlidePreview {
        ImplementationFixedLengthStepSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
