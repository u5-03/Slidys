//
//  ImplementationStepSlide.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/11/06.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct ImplementationStepSlide: View {
    var body: some View {
        HeaderSlide("Implementation Steps") {
            Item("Prepare a Path for the desired shape", accessory: .number(1))
            Item("Implement a Widget to display the Path", accessory: .number(2))
            Item("Make the Path display partially based on progress", accessory: .number(3))
            Item("Enable animation according to progress", accessory: .number(4))
        }
    }
}

#Preview {
    SlidePreview {
        ImplementationStepSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
