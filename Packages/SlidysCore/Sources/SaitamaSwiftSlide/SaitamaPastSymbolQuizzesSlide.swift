import SlideKit
import SlidesCore
import SwiftUI

@Slide struct SaitamaPastSymbolQuizzesSlide: View {
    var transition: AnyTransition { SlideTransition.defaultTransition }
    var script: String { "これまでも各地のシンボルを当てるクイズを作ってきました。今回は埼玉で、3Dモデルを使ってやってみます。" }
    var body: some View {
        HeaderSlide("これまでのシンボルクイズ") {
            RegionSymbolQuizView()
        }
    }
}

#Preview("過去のシンボルクイズ") {
    SlidePreview { SaitamaPastSymbolQuizzesSlide() }
        .slideTheme(CustomSlideTheme(showSlideIndex: false, listTextStyle: .large))
}
