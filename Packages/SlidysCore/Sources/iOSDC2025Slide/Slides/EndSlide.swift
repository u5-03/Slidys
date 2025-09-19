//
//  Created by yugo.a.sugiyama on 2025/09/15
//  Copyright ©Sugiy All rights reserved.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct EndSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("おわり") {
            HStack {
                VStack {
                    Text("本日の発表内容のブログ")
                        .font(.mediumFont)
                    Image(.iosdc2025ShareQr)
                        .resizable()
                        .scaledToFit()
                }
                Spacer()
                VStack {
                    HStack {
                        Image(.kanagawaSwift)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                        Text("#2 11/2 in 鎌倉")
                            .font(.mediumFont)
                    }
                    Image(.kanagawaSwift2Event)
                        .resizable()
                        .scaledToFit()
                }
            }
        }
    }
}

#Preview {
    SlidePreview {
        EndSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}

