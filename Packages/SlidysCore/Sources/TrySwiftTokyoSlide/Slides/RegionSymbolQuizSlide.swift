//
//  Created by yugo.sugiyama on 2025/03/12
//  Copyright ©Sugiy All rights reserved.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct RegionSymbolQuizSlide: View {

    var body: some View {
        HeaderSlide("I worked quizzes to guess the symbols of the region") {
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
