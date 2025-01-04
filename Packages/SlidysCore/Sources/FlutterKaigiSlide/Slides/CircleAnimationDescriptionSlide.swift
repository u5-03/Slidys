//
//  CircleAnimationDescriptionSlide.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/11/09.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct CircleAnimationDescriptionSlide: View {
    var body: some View {
        HeaderSlide("円環(アニメーション)") {
            Item("AnimatedBuilderを使って、angleを0->2 * math.piに変化させるアニメーションを実行し、かつそれを繰り返す設定をしている", accessory: .number(1))
            Item("そのangleをCustomMultiChildLayoutのContainerに渡すことで実現している", accessory: .number(2))
            Item("工夫次第で複雑なレイアウトのアニメーションも実現できる", accessory: .number(3))
        }
    }
}

#Preview {
    SlidePreview {
        CircleAnimationDescriptionSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
