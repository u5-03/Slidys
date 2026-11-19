import SlideKit
import SlidesCore
import SwiftUI

/// Kanagawa等と同じ、地域のシルエットに大きなタイトルを重ねる導入。
@Slide struct SaitamaQuizTitleSlide: View {
    var transition: AnyTransition { SlideTransition.defaultTransition }
    var script: String { "埼玉シンボルクイズ！いつものシンボルクイズを、今回は3Dでやってみます。" }
    var body: some View {
        ZStack {
            Color(.lightGray)
                .mask {
                    // 添付JPEGは白地・黒シルエットなので、輝度を反転してマスクにする。
                    Image("SaitamaSilhouette", bundle: .module)
                        .resizable().scaledToFit()
                        .colorInvert().luminanceToAlpha()
                }
                .offset(x: 80)
                .blur(radius: 8)
                .padding(120)
            Text("埼玉 シンボルクイズ！")
                .font(.extraLargeFont)
                .shadow(radius: 30, x: 20, y: 20)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundStyle(.strokeColor)
        }
        .background(.slideBackgroundColor)
    }
}

#Preview("埼玉 シンボルクイズ", traits: .fixedLayout(width: 1280, height: 720)) {
    SlidePreview { SaitamaQuizTitleSlide() }.slideTheme(CustomSlideTheme(showSlideIndex: false, listTextStyle: .large))
}

#Preview("裏向きのカード", traits: .fixedLayout(width: 1280, height: 720)) {
    SaitamaSymbolQuizView()
}
