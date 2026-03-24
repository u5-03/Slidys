//
//  Created by yugo.sugiyama on 2025/04/20
//  Copyright ©Sugiy All rights reserved.
//

import SwiftUI

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct JapanRegionSwiftMapSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("Recently Japan-\\\\(region).swift regional events are trending in the Swift community") {
            Image(.japanRegionSwiftMap)
                .resizable()
                .scaledToFit()
        }
    }
}

#Preview {
    SlidePreview {
        JapanRegionSwiftMapSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
