import SlideKit
import SlidesCore
import SwiftUI

/// 元動画をBackground Assetsから読み込み、表示中は自動でループ再生する。
@Slide struct SaitamaAppleStoreVideoSlide: View {
    var localVideoURL: URL? = nil
    var transition: AnyTransition { SlideTransition.defaultTransition }
    var script: String { "Apple Storeのデモのように、3Dモデルの気になる部分へフォーカスする見せ方です。" }
    var body: some View {
        VideoView(videoType: .appleStoreFocusDemo, seamlessLoop: true, localVideoURL: localVideoURL)
            .background(Color.slideBackgroundColor)
    }
}

@Slide struct SaitamaAppleStoreDetailSlide: View {
    var transition: AnyTransition { SlideTransition.defaultTransition }
    var script: String { "プラスのボタンをタップすると、その部分の解説へフォーカスできます。" }
    var body: some View {
        GeometryReader { proxy in
            Image("AppleStoreFocusDetail", bundle: .module)
                .resizable()
                .scaledToFit()
                .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .background(Color.slideBackgroundColor)
    }
}

#Preview("Apple Storeの動画") {
    // Preview agents cannot access AssetPackManager. Use the exact delivery file locally.
    let source = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent().deletingLastPathComponent()
        .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        .appendingPathComponent("asset-packs/slidys-videos/payload/apple_store_focus_demo.mov")
    SlidePreview {
        SaitamaAppleStoreVideoSlide(localVideoURL: source)
    }
}
#Preview("Apple Storeの詳細画像") {
    SlidePreview { SaitamaAppleStoreDetailSlide() }
}
