//
//  NodeContractSlide.swift
//  iOSDC2026Slide
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct NodeContractSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("モデルに「ノード契約」を仕込む") {
            Item("Blenderの空オブジェクト(Empty)はUSDZでは座標だけを持つノード(Xform)になる", accessory: .number(1))
            Item("これをアタッチメントポイントとしてモデル内に埋め込んでおく", accessory: .number(2)) {
                Item("WristAnchor: モデル原点 = 手首への固定点", accessory: .bullet)
                Item("DeckSlot / CardSlot_1...5 / SpellSlot_1...5: デッキとカード配置位置", accessory: .bullet)
                Item("カードゾーンは実物のカードサイズ(58mm × 88mm)に合わせる", accessory: .bullet)
            }
            Item("Swift側はfindEntity(named:)でノードを探すだけ", accessory: .number(3)) {
                Item("ノード名の取り決めさえ守れば、モデルの形状を作り直してもコードは無変更", accessory: .bullet)
            }
        }
    }
}

#Preview {
    SlidePreview {
        NodeContractSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
