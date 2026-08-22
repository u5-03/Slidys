//
//  PossibilitiesSlide.swift
//  iOSDC2026Slide
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct PossibilitiesSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("それでも広がる可能性") {
            Item("「アニメの中の道具を腕に装着して、自分の手で操作する」体験は現状のvisionOSでも成立する", accessory: .number(1))
            Item("今回使った要素はすべて汎用的な技術", accessory: .number(2)) {
                Item("Blenderモデル + ノード契約 → 商品モックや教育コンテンツの3D表示に", accessory: .bullet)
                Item("手首装着 + ローパス追従 → 腕時計型・ブレスレット型のUI全般に", accessory: .bullet)
                Item("SwiftUI Viewを3Dオブジェクトの表面に → 既存SwiftUI資産を空間アプリへ持ち込む近道に", accessory: .bullet)
            }
            Item("「いつかやってみたかった」が個人開発の範囲で形にできる時代になった", accessory: .number(3))
        }
    }
}

#Preview {
    SlidePreview {
        PossibilitiesSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
