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
    var body: some View {
        HeaderSlide("開催されたJapan-\\\\(region).swiftのイベント") {
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
