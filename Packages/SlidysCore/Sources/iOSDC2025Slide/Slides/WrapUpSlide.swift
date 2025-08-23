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
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("まとめ・補足") {
            Item("visionOSを使ったハンドジェスチャーの仕組みの基礎について確認", accessory: .number(1))
            Item("静的・動的ジェスチャーの検知についても確認", accessory: .number(2))
            Item("パフォーマンスや精度などで課題もある", accessory: .number(3)) {
                Item("手話との距離を縮めるきっかけにはなるかも？", accessory: .number(1)) {
                }
            }
            Item("EyeSightのような機能はコミュニケーションをする上では大事", accessory: .number(4))
            Item("手話も含めたコミュニケーションは伝えようとする気持ちが大事", accessory: .number(5))
            Item("もちろんこのスライドは@mtj_jさん🦌のSlideKit製です(11回目)", accessory: .number(6))
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

