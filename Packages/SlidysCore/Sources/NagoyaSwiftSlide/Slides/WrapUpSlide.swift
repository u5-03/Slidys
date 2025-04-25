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
            Item("Blurの仕組みの概要や使われ方について考えてみた", accessory: .number(1))
            Item("Apple Platformを含めて、BlurエフェクトがUXを考慮してどのように使われているかを考えるのも面白い", accessory: .number(2))
            Item("Blurは内部的にかなり重たい処理をしているので、多用すると負荷がかかる", accessory: .number(3)) {
                Item("どのような場面で使うべきなのかを、日頃からしっかり考えたい", accessory: .number(1)) {
                }
            }
            Item("愛知のあのシンボルは久々に見た", accessory: .number(4))
            Item("入院中はできることが制限されるので、集中できた", accessory: .number(5))
            Item("もちろんこのスライドは@mtj_jさん🦌のSlideKit製です(n回目)", accessory: .number(6))
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

