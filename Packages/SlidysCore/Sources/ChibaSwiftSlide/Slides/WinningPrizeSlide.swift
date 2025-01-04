//
//  WinningPrizeSlide.swift
//  ChibaSwiftSlide
//
//  Created by Yugo Sugiyama on 2024/09/09.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct WinningPrizeSlide: View {
    var body: some View {
        HeaderSlide("優勝賞品") {
            Item("千葉のなごみの米屋のお菓子", accessory: .number(1))
            Item("うちのパートナーの実家のお米", accessory: .number(2))
            HStack {
                Spacer()
                Image(.winningPrize)
                    .resizable()
                    .scaledToFit()
                Spacer()
            }
        }
    }
}

#Preview {
    SlidePreview {
        WinningPrizeSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}

