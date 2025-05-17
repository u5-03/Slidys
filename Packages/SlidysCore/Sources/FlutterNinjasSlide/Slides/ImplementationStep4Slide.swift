//
//  ImplementationStep4Slide.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/11/06.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct ImplementationStep4Slide: View {
    var body: some View {
        HeaderSlide("ステップ4 進捗率に応じて、アニメーションできるようにする") {
            Item("AnimationControllerやアニメーションの進捗値（progress）を用意する", accessory: .number(1)) {
                Item("AnimationControllerはflutter_hooksのuseAnimationControllerを使用しました", accessory: .number(1))
            }
            Item("progress値（0.0〜1.0）に応じて、Pathの描画範囲を動的に決定する", accessory: .number(2))
            Item("AnimationControllerのforward()やrepeat()を実行して、アニメーションを実行する", accessory: .number(3))
            Item("アニメーションの進行に合わせて、Pathが徐々に描画される", accessory: .number(4))
        }
    }
}

#Preview {
    SlidePreview {
        ImplementationStep4Slide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
