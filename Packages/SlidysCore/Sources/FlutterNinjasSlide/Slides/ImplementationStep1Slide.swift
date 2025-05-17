//
//  ImplementationStep1Slide.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/11/06.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct ImplementationStep1Slide: View {
    var body: some View {
        HeaderSlide("ステップ1 実現したい形のPathを用意する") {
            Item("簡単なPathの場合、そのまま自作するか、生成AIに任せる", accessory: .number(1))
            Item("複雑なもの場合、svgファイルとして作成し、そのPathの情報をFlutterのPathに変換するのがおすすめ", accessory: .number(2)) {
                Item("私はFigmaを使って、svgファイルの画像を作ることが多いです", accessory: .number(1))
                Item("Webの変換ツールを利用するのもあり", accessory: .number(2))
                Item("svgファイルから、PathDataを抽出し、Pathを生成する仕組みを作るのもあり", accessory: .number(3))
            }
            Item("これらのsvgやPathはoutlineされておらず、閉じていないものである必要があります", accessory: .number(3))
        }
    }
}

#Preview {
    SlidePreview {
        ImplementationStep1Slide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
