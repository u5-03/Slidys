//
//  WrapUpSlide.swift
//  iOSDC2026Slide
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct WrapUpSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("まとめ") {
            Item("モデルには「ロケーター」。形はBlender、形式はRCP、振る舞いはコード", keywords: ["ロケーター"], accessory: .number(1))
            Item("手首装着とジェスチャーは、関節の特性(ロスト・ブレ・つまみ中の縮退)込みで設計", keywords: ["関節の特性"], accessory: .number(2))
            Item("制約は多いが、「いつかやってみたかった」は個人開発でも形にできる", keywords: ["個人開発でも形にできる"], accessory: .number(3))
        }
    }
}

#Preview {
    SlidePreview {
        WrapUpSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
