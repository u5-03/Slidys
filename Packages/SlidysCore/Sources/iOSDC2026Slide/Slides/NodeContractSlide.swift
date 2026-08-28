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
            Item("Blenderの空オブジェクト = 形のない「目印のピン」", accessory: .number(1))
            Item("手首の固定点・5つのゾーン・デッキ・墓地・ライフ表示の位置に名前を付けて刺す", accessory: .number(2))
            Item("アプリは名前で探すだけ。モデルを作り直してもコードは無変更", accessory: .number(3))
        }
    }
}

#Preview {
    SlidePreview {
        NodeContractSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
