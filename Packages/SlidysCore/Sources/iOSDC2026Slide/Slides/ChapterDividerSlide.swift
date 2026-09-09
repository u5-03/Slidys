//
//  ChapterDividerSlide.swift
//  iOSDC2026Slide
//
//  章扉。「今日話すこと」の目次を並べ、これから話す章だけ活性表示にして
//  発表全体の中の現在地をわかりやすくする。
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct ChapterDividerSlide: View {
    /// これから話す章(0始まり)
    let activeIndex: Int
    /// スピーカーノート(発表者用の原稿。ノートWindowに表示される)
    var script: String = ""

    static let chapters = [
        "3Dモデルを用意して表示する",
        "Hand Gestureでカードを引く・持つ・置く",
        "エフェクトとアニメーションでそれらしくする",
    ]

    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 72) {
            ForEach(Array(Self.chapters.enumerated()), id: \.offset) { index, title in
                let isActive = index == activeIndex
                // 数字と文が上下にずれて見えないよう、行ブロックの縦中央で揃える
                HStack(alignment: .center, spacing: 40) {
                    Text("\(index + 1)")
                        .font(.system(size: isActive ? 100 : 72, weight: .heavy))
                        .foregroundStyle(isActive ? Color.themeColor : .defaultForegroundColor)
                        .frame(width: 110, alignment: .trailing)
                    // 折り返すと目次として読みにくいので、必ず1行に収める(収まらなければ自動縮小)
                    Text(title)
                        .font(.system(size: isActive ? 68 : 52, weight: isActive ? .heavy : .bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .foregroundStyle(.defaultForegroundColor)
                }
                .opacity(isActive ? 1 : 0.3)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(.horizontal, 140)
        .background(.slideBackgroundColor)
        .foregroundColor(.defaultForegroundColor)
    }
}

#Preview {
    SlidePreview {
        ChapterDividerSlide(activeIndex: 1)
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
