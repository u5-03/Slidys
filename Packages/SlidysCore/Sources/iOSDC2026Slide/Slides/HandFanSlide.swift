//
//  HandFanSlide.swift
//  iOSDC2026Slide
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct HandFanSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("左手の3本指「つまみ」で手札を持つ") {
            Item("3本指を合わせている間だけ、手札の扇を表示", keywords: ["3本指"], accessory: .number(1))
            Item("標準の2本指ピンチ(タップ操作)と混同しないための3本指", keywords: [], accessory: .number(2))
            Item("つまみ中は指先が1点に集まる → 扇の向きは付け根(ナックル)から計算", keywords: ["付け根(ナックル)"], accessory: .number(3))
        }
    }
}

#Preview {
    SlidePreview {
        HandFanSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
