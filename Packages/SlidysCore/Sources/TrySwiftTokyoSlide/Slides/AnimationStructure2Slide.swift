//
//  Created by yugo.sugiyama on 2025/03/16
//  Copyright ©Sugiy All rights reserved.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct AnimationStructure2Slide: View {
    var body: some View {
        HeaderSlide("Structure of animation implementation") {
            Item("Set the `trimmedPath` function of path to enable trimming strokes according to animatableData", accessory: .number(1))
            Item("Run an animation that changes the value passed to animatableData from 0 to 1", accessory: .number(2))
        }
    }
}

#Preview {
    SlidePreview {
        AnimationStructure2Slide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}

