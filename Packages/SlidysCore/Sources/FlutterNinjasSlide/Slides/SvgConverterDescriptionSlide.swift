//
//  SvgConverterDescriptionSlideswift.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/11/06.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct SvgConverterDescriptionSlideswift: View {
    var body: some View {
        HeaderSlide("自作したsvgからFlutterのPathへの変換ロジック") {
            Item("xmlプラグインを使って、SVGファイルをテキストとして読み込み、XMLとしてパースする", accessory: .number(1))
            Item("<path>要素を抽出し、各要素のd属性(パスデータ)を取得する", accessory: .number(2))
            Item("path_drawingプラグインを使って、d属性のパスデータをFlutterのPathオブジェクトに変換する", accessory: .number(3))
            Item("addPath()を使って、必要に応じて複数のPathを1つに統合する", accessory: .number(4))
        }
    }
}

#Preview {
    SlidePreview {
        SvgConverterDescriptionSlideswift()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
