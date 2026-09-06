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
        HeaderSlide("モデルとコードを疎結合につなぐ") {
            Item("ディスクのオブジェクト内のカード置き場やデッキ、手首の配置座標などは、アプリ内で取得するためにロケーターでつなぐ", keywords: ["ロケーター"], accessory: .number(1))
            Item("Blenderの空オブジェクト(Empty) = 形のない目印をロケーターとして配置し、アプリ内から参照できるようにする", keywords: ["空オブジェクト(Empty)"], accessory: .number(2))
            Item("アプリは名前で探すだけ。モデルを作り直してもその名前が変わらなければ、コードは変更不要", keywords: ["コードは無変更"], accessory: .number(3))
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
