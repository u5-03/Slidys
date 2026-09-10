//
//  LocatorShowcaseSlide.swift
//  iOSDC2026Slide
//
//  ロケーターの実物: Blender上の空オブジェクト配置と、
//  アウトライナーに並ぶ名前(WristAnchor / Zone_* など)を見せる。
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct LocatorShowcaseSlide: View {
    /// スピーカーノート(発表者用の原稿。ノートWindowに表示される)
    var script: String {
        "Blenderではこんな感じになっています。この辺はすべて空オブジェクトです。この命名をSwiftのコード側で参照します。"
    }

    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("ロケーターの実物") {
            Image(.blenderLocatorNodes)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.15), lineWidth: 2)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    SlidePreview {
        LocatorShowcaseSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
