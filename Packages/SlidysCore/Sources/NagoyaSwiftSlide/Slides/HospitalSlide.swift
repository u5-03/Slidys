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
        GeometryReader { proxy in
            HeaderSlide("try!SwiftTokyo2024の翌々日~の入院中") {
                HStack(alignment: .center, spacing: 0) {
                    Image(.hospitalTweet)
                        .resizable()
                        .scaledToFit()
                        .frame(width: proxy.size.width / 2)
                    Image(.hospitalRoom)
                        .resizable()
                        .scaledToFit()
                        .frame(width: proxy.size.width / 2)
                }
            }
            .padding(80)
            .frame(height: proxy.size.height)
            .background(.slideBackgroundColor)
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
