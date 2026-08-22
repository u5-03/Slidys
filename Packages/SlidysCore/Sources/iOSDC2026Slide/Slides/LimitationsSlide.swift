//
//  LimitationsSlide.swift
//  iOSDC2026Slide
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct LimitationsSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("再現してみてわかった制約") {
            ScrollView {
                Item("腕とデバイスのオクルージョンが不完全", accessory: .number(1)) {
                    Item("❌ 上肢表示は画面空間のセグメンテーションで、腕時計のような連続的な遮蔽は不可", accessory: .bullet)
                    Item("→ 手首を返したときだけ.automaticに切り替えるヒステリシス付きの妥協案", accessory: .bullet)
                }
                Item("手首トラッキングは頻繁にロストする", accessory: .number(2)) {
                    Item("❌ 視野の端や体の影に入りやすい。素早く腕を振ると追従が目に見えて遅れる", accessory: .bullet)
                }
                Item("ピンチ中の指先からは手の向きが取れない(付け根関節の併用が必須)", accessory: .number(3))
                Item("SwiftUIのAttachmentは背面が鏡写しに透ける(裏面用の板で対処)", accessory: .number(4))
                Item("シミュレータではハンドトラッキングが動かず、開発イテレーションは実機装着が基本", accessory: .number(5))
                Item("mixed immersionでは現実の部屋は照らせない(「部屋全体が光る」演出は不成立)", accessory: .number(6))
            }
        }
    }
}

#Preview {
    SlidePreview {
        LimitationsSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
