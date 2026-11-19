import SlideKit
import SlidesCore
import SwiftUI

@Slide struct SaitamaTitleMeaningSlide: View {
    var transition: AnyTransition { SlideTransition.defaultTransition }
    var script: String { "あの日はiOSDC2026の初日。3Dモデルの見せ方は、その実装の詳細や活用方法。僕たちは発表の視聴者を指しています。あの日は省略した実装の話を今日はお伝えします。" }
    var body: some View {
        Text("あの日(iOSDC2026の初日)観た3Dモデルの見せ方(の実装の詳細や活用方法)を僕たち(発表の視聴者)はまだ知らない")
            .font(.system(size: 74, weight: .bold))
            .multilineTextAlignment(.center)
            .lineSpacing(24)
            .padding(110)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.slideBackgroundColor).foregroundStyle(.defaultForegroundColor)
    }
}
#Preview("タイトルの意味", traits: .fixedLayout(width: 1280, height: 720)) {
    SlidePreview { SaitamaTitleMeaningSlide() }.slideTheme(CustomSlideTheme(showSlideIndex: false, listTextStyle: .large))
}
