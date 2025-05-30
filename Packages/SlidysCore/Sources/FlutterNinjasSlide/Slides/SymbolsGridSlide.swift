//
//  Created by yugo.sugiyama on 2025/05/18
//  Copyright ©Sugiy All rights reserved.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct SymbolsGridSlide: View {

    private let selectedSymbolPosition: SymbolPosition?

    init(selectedSymbolPosition: SymbolPosition? = nil) {
        self.selectedSymbolPosition = selectedSymbolPosition
    }

    var body: some View {
        HeaderSlide("Symbol quizzes from regional events I've conducted") {
            RegionSymbolQuizView(selectedSymbolPosition: selectedSymbolPosition)
        }
    }
}

#Preview {
    SlidePreview {
        SymbolsGridSlide(selectedSymbolPosition: .bottomLeft)
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
