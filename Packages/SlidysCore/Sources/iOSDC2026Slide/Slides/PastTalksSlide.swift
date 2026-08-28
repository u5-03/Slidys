//
//  PastTalksSlide.swift
//  iOSDC2026Slide
//
//  これまでのiOSDC登壇(2022〜2025)のプロポーザル画像を2×2のタイルで並べる。
//  画像は Assets.xcassets/Proposal_Photos/proposal_YYYY (1200×630)。
//  文字はプロポーザル画像自体に入っているのでキャプションは付けない。
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct PastTalksSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    private let rows: [[ImageResource]] = [
        [.proposal2022, .proposal2023],
        [.proposal2024, .proposal2025],
    ]

    var body: some View {
        HeaderSlide("これまでのiOSDCでの発表") {
            // 見出し以外の残り領域を全部使い、2行×2列で均等に割り当てる。
            // 各タイルは割り当て枠の中に scaledToFit で収めるので、画像の縦横比を保ったまま見切れない。
            GeometryReader { proxy in
                let rowSpacing: CGFloat = 32
                let columnSpacing: CGFloat = 48
                let rowHeight = (proxy.size.height - rowSpacing) / 2
                VStack(spacing: rowSpacing) {
                    ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                        HStack(spacing: columnSpacing) {
                            ForEach(row, id: \.self) { image in
                                Image(image)
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                                            .strokeBorder(Color.white.opacity(0.15), lineWidth: 2)
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: rowHeight)
                            }
                        }
                        .frame(height: rowHeight)
                    }
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
            }
        }
    }
}

#Preview {
    SlidePreview {
        PastTalksSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
