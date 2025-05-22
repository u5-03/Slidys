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
            Item("I used useAnimationController from flutter_hooks for the AnimationController ", accessory: .number(2))
            Item("Dynamically determine the drawing range of the Path according to the progress value (0.0-1.0)", accessory: .number(3))
            Item("Execute forward() or repeat() of the AnimationController to run the animation", accessory: .number(4))
            Item("The Path is gradually drawn as the animation progresses", accessory: .number(5))
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
