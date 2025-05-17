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
        HeaderSlide("最近SwiftコミュニティでもJapan-\\\\(region).swiftの地域イベントが流行") {
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
