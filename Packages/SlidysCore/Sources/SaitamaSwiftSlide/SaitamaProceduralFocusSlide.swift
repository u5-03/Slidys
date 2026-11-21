import SlideKit
import SlidesCore
import SwiftUI

@Slide struct SaitamaProceduralFocusSlide: View {
    var transition: AnyTransition { SlideTransition.defaultTransition }
    var script: String { "【20秒】こちらはAstraにSwiftのコードだけで作ってもらったたい焼きです。モデルファイルもBlenderのEmptyもありません。こちらも自動で左右に1回転し、具材を順番に切り替えます。必要なら目・尾びれ・背びれ・焼印のプラスをタップできます。空のEntityをコードで置くことで、同じフォーカスと解除の動きを実現できます。" }
    var body: some View {
        HeaderSlide("Swiftだけで作ったたい焼きフォーカスの実装") {
            TaiyakiFocusView(mode: .full, fontScale: 2.1, modelScale: 1.2, modelSource: .procedural, automaticDemo: true)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .excludesFromSlideTapNavigation()
        }
    }
}

#Preview("Swiftメッシュの部位フォーカス", traits: .fixedLayout(width: 1280, height: 720)) {
    SlidePreview { SaitamaProceduralFocusSlide() }.slideTheme(CustomSlideTheme(showSlideIndex: false, listTextStyle: .large))
}
