//
//  ParticleEffectSlide.swift
//  iOSDC2026Slide
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct ParticleEffectSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("召喚バーストはRCPで作ったパーティクル") {
            Item("線・スパークル・光球の3エミッタ。見た目はRCPで追い込む", accessory: .number(1))
            Item("ブルームが無いので、加算ブレンドで「白飛び=光」", accessory: .number(2))
            Item("床を突き抜ける → 見えない壁で下半分を隠して半球ドーム", accessory: .number(3))
        }
    }
}

#Preview {
    SlidePreview {
        ParticleEffectSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
