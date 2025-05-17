//
//  ImplementationStep2Slide.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/11/06.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct ImplementationStep2Slide: View {
    var body: some View {
        HeaderSlide("ステップ2 そのPathを表示するWidgetを実装する") {
            Item("ステップ1で生成したFlutterのPathオブジェクトを用意する", accessory: .number(1))
            Item("PathオブジェクトをCustomPainterのpaintメソッドでcanvas.drawPath(path, paint)として描画する", accessory: .number(2))
            Item(" CustomPainterをCustomPaintウィジェットにセットし、画面上にSVGのパスを表示する", accessory: .number(3))
        }
    }
}

#Preview {
    SlidePreview {
        ImplementationStep2Slide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
