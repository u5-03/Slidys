//
//  TaiyakiRealityKitDemoSlide.swift
//  iOSDC2026Slide
//
//  One more thingパート: Swiftだけで手続き的に生成したたい焼き(TaiyakiRealityKitSampleView)を
//  スライド全面に埋め込み、その場でドラッグ回転・ピンチ拡大のデモができるようにする。
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct TaiyakiRealityKitDemoSlide: View {
    /// スピーカーノート(発表者用の原稿。ノートWindowに表示される)
    var script: String {
        "こちらがその後調整したものです。左側はBlenderもReality Composer Proも使っていません。メッシュもテクスチャも全部Swiftで手続き的に生成しています。"
    }

    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("最終的に調整したバージョン") {
            // 左: Astra(Swift手続き生成) / 右: Blenderでモデリングしたusdz。
            // ビューアの見た目・操作は共通(TaiyakiRealityKitSampleView)。
            HStack(spacing: 40) {
                viewer(source: .procedural, label: "AIが生成(Swiftのみ)")
                viewer(source: .blenderUSDZ, label: "Blenderでモデリング")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func viewer(
        source: TaiyakiRealityKitSampleView.ModelSource,
        label: String
    ) -> some View {
        VStack(spacing: 20) {
            Text(label)
                .font(.system(size: 44, weight: .bold))
            TaiyakiRealityKitSampleView(
                source: source,
                showsInfoTexts: false,
                fontScale: 1.7,
                modelScale: 1.2
            )
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    SlidePreview {
        TaiyakiRealityKitDemoSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
