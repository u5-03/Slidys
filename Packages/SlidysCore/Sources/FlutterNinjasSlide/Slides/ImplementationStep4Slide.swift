//
//  ImplementationStep4Slide.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/11/06.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct ImplementationStep4Slide: View {
    var body: some View {
        HeaderSlide("Step 4: Enable animation according to progress") {
            Item("Prepare an AnimationController and animation progress value", accessory: .number(1))
            Item("Set the animation duration to AnimationController", accessory: .number(2))
            Item("Execute forward() or repeat() of the AnimationController to run the animation according to the progress value (0.0-1.0)", accessory: .number(3))
            Item("The Path is gradually drawn as the animation progresses", accessory: .number(4))
        }
    }
}

#Preview {
    SlidePreview {
        ImplementationStep4Slide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
