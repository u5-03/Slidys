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
            Item("オブジェクトの形はBlender、エフェクト調整はRCP、細かい振る舞いはコードで実現", keywords: [], accessory: .number(1))
            Item("トラッキングのロストやブレはvisionOS側の制約。\n起きる前提で、追従や補間を設計する", keywords: ["起きる前提"], accessory: .number(2))
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
