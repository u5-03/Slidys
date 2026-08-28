//
//  SummonSequenceSlide.swift
//  iOSDC2026Slide
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct SummonSequenceSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("召喚シーケンスの全体像") {
            Item("ディスク上: 置いたゾーンから盤面全体へ光のライン", accessory: .number(1))
            Item("フィールド: カードが出現して上昇 + 足元で放射状の光のバースト", accessory: .number(2))
            Item("1秒後、光の中からモンスターがフェードイン+せり上がり", accessory: .number(3))
            Item("置いた場所と出る場所が離れているので、両方に演出を入れて視線を誘導", accessory: .bullet)
        }
    }
}

#Preview {
    SlidePreview {
        SummonSequenceSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
