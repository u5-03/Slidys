//
//  Created by yugo.sugiyama on 2025/03/12
//  Copyright ©Sugiy All rights reserved.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct RegionSymbolQuizSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("これまでのJapan-\\\\(region).swiftでご当地シンボルクイズをやってきました") {
            RegionSymbolQuizView()
        }
    }
}

#Preview {
    SlidePreview {
        RegionSymbolQuizSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
