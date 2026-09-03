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
        HeaderSlide("モデルに「ロケーター」を仕込む") {
            Item("モデルとコードは、名前を付けたロケーターでつなぐ", keywords: ["ロケーター"], accessory: .number(1))
            Item("Blenderの空オブジェクト(Empty) = 形のない目印。ゾーン・デッキ・墓地・手首・ライフに置く", keywords: [], accessory: .number(2))
            Item("アプリは名前で探すだけ。モデルを作り直してもコードは無変更", keywords: ["コードは無変更"], accessory: .number(3))
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
