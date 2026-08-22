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
            Item("デバイス上: カードを置いたゾーンから盤面全体へ光のラインが伸びる(SwiftUIエフェクト)", accessory: .number(1))
            Item("フィールド: カードが出現し、ゆっくり上昇する(move(to:))", accessory: .number(2))
            Item("同時に足元でパーティクルが弾け、光の柱が立ち上る(ParticleEmitterComponent)", accessory: .number(3))
            Item("1秒後、光の柱の中からモンスターがフェードイン + せり上がりで出現", accessory: .number(4))
            Item("カードを置いた場所とモンスターが出る場所が離れているので、両方に演出を入れて視線誘導する", accessory: .bullet)
        }
    }
}

#Preview {
    SlidePreview {
        SummonSequenceSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
