//
//  WrapUpSlide.swift
//  KanagawaSwiftSlide
//
//  Created by Yugo Sugiyama on 2024/09/09.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct WrapUpSlide: View {
    var body: some View {
        HeaderSlide("まとめ・補足") {
            Item("SwiftUIのStrokeのアニメーション方法について解説", accessory: .number(1))
            Item("Strokeのアニメーションを使った大阪シンボル？クイズをしました", accessory: .number(2)) {
                Item("楽しかったですか？", accessory: .number(1))
            }
            Item("ちなみにSwiftUIのwithAnimationはアニメーションの中断・再開ができないので、今回のクイズ用に中断・再開ができる仕組みをSwiftUIで無理やり実装しました", accessory: .number(3)) {
            }
            Item("もちろんこのスライドは@mtj_jさん🦌のSlideKit製です笑", accessory: .number(4))
        }
    }
}

#Preview {
    SlidePreview {
        WrapUpSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}

