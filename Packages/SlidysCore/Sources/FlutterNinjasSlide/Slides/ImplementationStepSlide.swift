//
//  ImplementationStepSlide.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/11/06.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct ImplementationStepSlide: View {
    var body: some View {
        HeaderSlide("実装ステップ") {
            Item("実現したい形のPathを用意する", accessory: .number(1))
            Item("そのPathを表示するWidgetを実装する", accessory: .number(2))
            Item("Pathを進捗率によって、Pathを部分的に表示できるようにする", accessory: .number(3))
            Item("進捗率に応じて、アニメーションできるようにする", accessory: .number(4))
        }
    }
}

#Preview {
    SlidePreview {
        ImplementationStepSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
