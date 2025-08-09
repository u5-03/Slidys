//
//  DescriptionSlide.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/11/06.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct DescriptionSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("CustomMultiChildLayoutとは？") {
            Item("複数のWidgetのレイアウトを制御し、それぞれ任意の位置に配置するWidget", accessory: .number(1))
            Item("ColumnやRow, Stackのようなものを自作することができる", accessory: .number(2))
            Item("WidgetごとにIDを割り振るので、IDごとに条件も指定できる", accessory: .number(3))
            Item("親のWidgetのサイズを考慮して、子どものWidgetのサイズや 位置を指定できる", accessory: .number(4))
        }
    }
}

#Preview {
    SlidePreview {
        DescriptionSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
