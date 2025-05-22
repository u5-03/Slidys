//
//  ImplementationStep1Slide.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/11/06.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct ImplementationStep1Slide: View {
    var body: some View {
        HeaderSlide("Step 1: Prepare a Path for the desired shape") {
            Item("For simple Paths, create them yourself or use generative AI", accessory: .number(1))
            Item("For complex ones, recommend creating as SVG files and converting that Path information to Flutter's Path", accessory: .number(2)) {
                Item("I often use Figma to create SVG file images", accessory: .number(1))
                Item("Using web conversion tools is also an option", accessory: .number(2))
                Item("Another option is to build a mechanism to extract PathData from SVG files and generate Paths", accessory: .number(3))
            }
            Item("These SVG and Path files need to be not outlined and not closed", accessory: .number(3))
        }
    }
}

#Preview {
    SlidePreview {
        ImplementationStep1Slide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
