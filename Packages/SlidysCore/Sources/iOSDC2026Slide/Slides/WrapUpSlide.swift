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
            Item("モデルには「ノード契約」。形はBlender、見た目の調整はRCP、振る舞いはコード", accessory: .number(1))
            Item("手首装着とジェスチャーは、関節の特性(ロスト・ブレ・つまみ中の縮退)込みで設計する", accessory: .number(2))
            Item("制約は多いが、「いつかやってみたかった」は個人開発でも形にできる", accessory: .number(3))
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
