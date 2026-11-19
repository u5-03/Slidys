import SlideKit
import SlidesCore
import SwiftUI

@Slide struct SaitamaReadmeSlide: View {
    var script: String { "すぎーです。DeNAのiOS / Flutterエンジニアで、今はiPadOSアプリのプロジェクトにいます。Kanagawa.swiftの運営もしています。埼玉にちゃんと来たのは初めてです。" }
    var transition: AnyTransition { SlideTransition.defaultTransition }
    private let items = [
        "DeNAのiOS / Flutterエンジニア",
        "今はiPadOSのアプリのプロジェクト",
        "Kanagawa.swiftの運営をしてます",
        "埼玉にちゃんと来たのは初めてです"
    ]
    var body: some View {
        VStack(alignment: .leading, spacing: 48) {
            VStack(alignment: .leading, spacing: 28) {
                Text("自己紹介").font(.system(size: 80, weight: .heavy)).foregroundStyle(.themeColor)
                Text("すぎー / Sugiy").font(.system(size: 66, weight: .bold))
            }
            .padding(.trailing, 400)
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                Text("\(index + 1). \(item)")
                    .font(.system(size: 60, weight: .semibold))
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(90)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .overlay(alignment: .topTrailing) {
            Image(.iconDynamic).resizable().scaledToFit()
                .frame(width: 360, height: 360)
                .clipShape(Circle())
                .padding(90)
        }
        .background(.slideBackgroundColor).foregroundStyle(.defaultForegroundColor)
    }
}

#Preview("自己紹介", traits: .fixedLayout(width: 1280, height: 720)) {
    SlidePreview { SaitamaReadmeSlide() }.slideTheme(CustomSlideTheme(showSlideIndex: false, listTextStyle: .large))
}
