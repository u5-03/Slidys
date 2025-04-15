//
//  AnimationStructureSlide.swift
//  KanagawaSwiftSlide
//
//  Created by Yugo Sugiyama on 2024/09/08.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct GaussianBlurSlide: View {
    var body: some View {
        HeaderSlide("GaussianBlurとは？") {
            Item("ガウス分布(正規分布)を使ったBlurの処理", accessory: .number(1))
            Item("対象ピクセルに周囲のピクセルを加味して、平均的な色に変更する", accessory: .number(2))
            Item("ガウス分布を用いて、重み付をして反映する", accessory: .number(3)) {
                Item("中心のピクセル→重め、周囲のピクセル→軽め", accessory: .number(1))
            }
            Item("この処理を対象の範囲のピクセル全てに適用する", accessory: .number(4))
            Item("各ピクセルの計算時に周囲のより広い範囲を計算対象にすれば、滑らかなBlurになるが、その分計算負荷が高くなる", accessory: .number(5))
        }
    }
}

#Preview {
    SlidePreview {
        GaussianBlurSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}

