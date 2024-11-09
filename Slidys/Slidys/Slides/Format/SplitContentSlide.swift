//
//  TitleSplitSlide.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/11/05.
//

import SwiftUI
import SlideKit

@Slide
struct SplitContentSlide<Content1: View, Content2: View>: View {
    let leadingWidthRatio: CGFloat
    let leadingContent: Content1
    let trailingContent: Content2

    init(
        leadingWidthRatio: CGFloat = 0.5,
        @ViewBuilder leadingContent: () -> Content1,
        @ViewBuilder trailingContent: () -> Content2
    ) {
        self.leadingWidthRatio = leadingWidthRatio
        self.leadingContent = leadingContent()
        self.trailingContent = trailingContent()
    }

    var body: some View {
        GeometryReader { proxy  in
            HStack(spacing: 32) {
                leadingContent
                    .padding(.leading, 52)
                    .foregroundStyle(.defaultForegroundColor)
                    .frame(width: proxy.size.width * leadingWidthRatio, alignment: .leading)
                trailingContent
                    .padding(.trailing, 120)
                    .frame(width: proxy.size.width * (1 - leadingWidthRatio), alignment: .center)
            }
            .frame(maxHeight: .infinity)
            .padding(.horizontal, 32)
        }
        .background(.slideBackgroundColor)
    }
}

#Preview {
    SplitContentSlide(leadingWidthRatio: 0.65) {
        HeaderSlide("play-by-sportsの配信・視聴画面") {
            Item("ライブ配信のアプリは画面上に多くの機能のコンポーネントを配置する必要がある", accessory: .number(1))
            Item("新規アプリなので、今後の変更頻度も高そう", accessory: .number(1)) {
                Item("Paddingの調整やボタンの追加などがよくある", accessory: .number(1))
            }
            Item("現時点ですでにかなり複雑な配置になっている", accessory: .number(1)) {
                Item("①~④のパーツを→の位置に配置", accessory: .number(1))
            }
            Item("上記の理由から、配置するパーツはコンポーネントとして用意し、その配置・調整はPaddingなども含め、CustomMultiChildLayoutで設定している", accessory: .number(1))
        }
    } trailingContent: {
        Image(.playBySportsImageOverlay)
            .resizable()
            .scaledToFit()
            .padding(.horizontal, 20)
    }
}
