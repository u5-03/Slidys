//
//  AnimationStructureSlide.swift
//  ChibaSwiftSlide
//
//  Created by Yugo Sugiyama on 2024/09/08.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct AnimationStructureSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("アニメーションの実装の仕組み") {
            Item("描きたい画像をPathで描く", accessory: .number(1)) {
                Item("SVG画像を用意する", accessory: .number(1))
                Item("'SVG to SwiftUI'などでSVGをSwiftUIのPathに変換する", accessory: .number(2))
            }
            Item("animatableDataを定義したShapeのpathを設定する", accessory: .number(2)) {
                Item("Animatable: アニメーションの対象となるデータを管理し、ViewやShapeがどのようにアニメーションされるかを定義する仕組み", accessory: .number(1))
            }
            Item("pathのtrimmedPath関数を設定し、animatableDataに応じたtrimができるようにする", accessory: .number(3))
            Item("animatableDataに渡した値を0->1に変更するアニメーションを実行する", accessory: .number(4))
        }
    }
}

#Preview {
    SlidePreview {
        AnimationStructureSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}

