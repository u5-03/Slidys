//
//  LiveDescriptionSlide.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/11/09.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct LiveDescriptionSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        SplitContentSlide(leadingWidthRatio: 0.65) {
            HeaderSlide("play-by-sportsの配信・視聴画面") {
                Item("ライブ配信のアプリは画面上に多くの機能のコンポーネントを配置する必要がある", accessory: .number(1))
                Item("新規アプリなので、今後の変更頻度も高そう", accessory: .number(2)) {
                    Item("Paddingの調整やボタンの追加などがよくある", accessory: .number(1))
                }
                Item("現時点ですでにかなり複雑な配置になっている", accessory: .number(3)) {
                    Item("①~④のパーツを→の位置に配置", accessory: .number(1))
                }
                Item("上記の理由から、配置するパーツはコンポーネントとして用意し、その配置・調整はPaddingなども含め、CustomMultiChildLayoutで設定している", accessory: .none)
            }
        } trailingContent: {
            Image(.playBySportsImageOverlay)
                .resizable()
                .scaledToFit()
                .padding(.horizontal, 20)
        }

    }
}

#Preview {
    SlidePreview {
        LiveDescriptionSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
