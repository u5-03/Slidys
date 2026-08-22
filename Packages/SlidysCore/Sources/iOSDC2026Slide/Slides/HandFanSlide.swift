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
        HeaderSlide("左手のピンチで手札を扇状に持つ") {
            Item("左手の親指・人差し指・中指の3本ピンチ中だけ、扇状の手札を表示", accessory: .number(1)) {
                Item("位置は指先(ピンチ中点)、向きは手のひらの基底に追従", accessory: .bullet)
            }
            Item("ハマりどころ: ピンチ中は指先が1点に集まり、指先からは手の向きの基底が作れない", accessory: .number(2)) {
                Item("→ ピンチの影響を受けない付け根(ナックル)関節から基底を作る", accessory: .bullet)
            }
            Item("ハマりどころ: 手のひら法線の外積は左手と右手で順序が逆(鏡像関係)", accessory: .number(3)) {
                Item("右手のロジックをコピーすると、カードが手の甲側に出る", accessory: .bullet)
            }
            Item("扇レイアウトはカード1枚あたり8°回転 + 選択中カードだけ持ち上げ", accessory: .number(4))
        }
    }
}

#Preview {
    SlidePreview {
        HandFanSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
