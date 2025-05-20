//
//  Created by yugo.sugiyama on 2025/05/18
//  Copyright ©Sugiy All rights reserved.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct SymbolsGridSlide: View {

    var body: some View {
        HeaderSlide("Symbol quizzes from regional events I've conducted") {
            RegionSymbolQuizView()
        }
    }
}

#Preview {
    SlidePreview {
        SymbolsGridSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
