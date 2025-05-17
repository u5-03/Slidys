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
        HeaderSlide("私がこれまで実施してきた地域イベントでのシンボルクイズ") {
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
