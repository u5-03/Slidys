//
//  Created by yugo.sugiyama on 2025/03/16
//  Copyright ©Sugiy All rights reserved.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct AnimationStructure1Slide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("Structure of animation implementation") {
            Item("Prepare the path of the shape", accessory: .number(1)) {
                Item("Prepare svg image and convert it to SwiftUI Path with a conversion tool", accessory: .number(1))
            }
            Item("Set the Shape of the path that defines the animatableData managing animation", accessory: .number(2)) {
                Item("Animatable allows custom animations in SwiftUI by interpolating values via animatableData", accessory: .number(1))
                Item("Set animation progress to animatableData", accessory: .number(2))
            }
        }
    }
}

#Preview {
    SlidePreview {
        AnimationStructure1Slide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}

