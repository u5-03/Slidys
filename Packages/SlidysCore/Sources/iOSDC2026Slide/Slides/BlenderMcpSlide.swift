//
//  BlenderMcpSlide.swift
//  iOSDC2026Slide
//
//  簡単なモデルならBlender MCP経由でAIに作らせられる、という紹介スライド。
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct BlenderMcpSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("簡単なモデルならAIでも作れる(Blender MCP)") {
            Item("Blender MCPを使うと、AIがBlenderを直接操作してモデリングできる", accessory: .number(1))
            Item("「こういうモデルを作って」と頼むだけで、土台になる形はできてしまう", accessory: .number(2))
            Item("細かい調整は人間が引き取る。まずAIに任せてみるのがおすすめ", accessory: .number(3))
        }
    }
}

#Preview {
    SlidePreview {
        BlenderMcpSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
