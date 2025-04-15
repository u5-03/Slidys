//
//  Created by yugo.sugiyama on 2025/04/16
//  Copyright ©Sugiy All rights reserved.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct HospitalSlide: View {
    var body: some View {
        HeaderSlide("try!SwiftTokyo2024の翌々日~の入院中") {
            HStack {
                Image(.hospitalTweet)
                    .resizable()
                    .scaledToFit()
                Image(.hospitalRoom)
                    .resizable()
                    .scaledToFit()
            }
        }
    }
}

#Preview {
    SlidePreview {
        HospitalSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
