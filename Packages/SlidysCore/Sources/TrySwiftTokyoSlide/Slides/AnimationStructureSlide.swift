//
//  Created by yugo.sugiyama on 2025/03/16
//  Copyright ©Sugiy All rights reserved.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct AnimationStructureSlide: View {
    var body: some View {
        HeaderSlide("Structure of animation implementation") {
            Item("Prepare path of shape", accessory: .number(1)) {
                Item("Prepare svg image and convert it to SwiftUI Path", accessory: .number(1))
            }
            Item("Set the path of the Shape that defines the animatableData", accessory: .number(2)) {
                Item("Animatable allows custom animations in SwiftUI by interpolating values via animatableData", accessory: .number(1))
            }
            Item("Set the `trimmedPath` function of path to enable trimming according to animatableData", accessory: .number(3))
            Item("Run an animation that changes the value passed to animatableData from 0 to 1", accessory: .number(4))
        }
    }
}

#Preview {
    SlidePreview {
        AnimationStructureSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}

