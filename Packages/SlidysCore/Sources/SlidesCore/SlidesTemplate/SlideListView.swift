//
//  SlideListView.swift
//  SlidesCore
//
//  デッキの全スライドをサムネイルのグリッドで一覧表示する共通View。
//  - SlideGridView: スクロール無しの「素のグリッド」。固有サイズを持つので
//    Xcodeプレビュー(.sizeThatFitsLayout)や ImageRenderer でもそのまま描画できる。
//  - SlideListView: SlideGridView を GeometryReader + ScrollView で包んだアプリ用。
//  SlideRouterView と同じく `AnyView(slide)` で描画するため、フェーズ付きスライドは
//  最初のフェーズの見た目で表示される。
//

import SwiftUI
import SlideKit

/// スクロール無しでスライドを列数×タイル幅のグリッドに敷き詰めるView。
/// 高さは行数から決まる固有サイズになる(プレビューや画像書き出し向き)。
public struct SlideGridView: View {
    private let slides: [any Slide]
    private let theme: CustomSlideTheme
    private let slideSize: CGSize
    private let columns: Int
    private let tileWidth: CGFloat

    private let tileSpacing: CGFloat = 20
    private let outerPadding: CGFloat = 20
    private let captionHeight: CGFloat = 22

    /// - Parameters:
    ///   - slideIndexController: 一覧化するデッキの SlideIndexController。
    ///   - listTextStyle: デッキ本体と同じリスト文字サイズを渡すと、本番と同じ見た目になる。
    ///   - columns: 列数(既定 4)。
    ///   - tileWidth: タイル1枚の幅(既定 440)。
    ///   - slideSize: スライドの原寸(既定 16:9 = 1920x1080)。
    public init(
        slideIndexController: SlideIndexController,
        listTextStyle: ListTextStyle = .standard,
        columns: Int = 4,
        tileWidth: CGFloat = 440,
        slideSize: CGSize = SlideSize.standard16_9
    ) {
        self.init(
            slides: slideIndexController.slides,
            listTextStyle: listTextStyle,
            columns: columns,
            tileWidth: tileWidth,
            slideSize: slideSize
        )
    }

    init(
        slides: [any Slide],
        listTextStyle: ListTextStyle,
        columns: Int,
        tileWidth: CGFloat,
        slideSize: CGSize = SlideSize.standard16_9
    ) {
        self.slides = slides
        self.theme = CustomSlideTheme(showSlideIndex: false, listTextStyle: listTextStyle)
        self.columns = max(1, columns)
        self.tileWidth = tileWidth
        self.slideSize = slideSize
    }

    public var body: some View {
        let tileHeight = tileWidth * slideSize.height / slideSize.width
        VStack(alignment: .leading, spacing: tileSpacing) {
            ForEach(Array(stride(from: 0, to: slides.count, by: columns)), id: \.self) { rowStart in
                HStack(alignment: .top, spacing: tileSpacing) {
                    ForEach(rowStart..<min(rowStart + columns, slides.count), id: \.self) { index in
                        VStack(alignment: .leading, spacing: 4) {
                            thumbnail(of: slides[index], width: tileWidth, height: tileHeight)
                            Text("\(index + 1) / \(slides.count)   \(String(describing: type(of: slides[index])))")
                                .font(.system(size: 13))
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                                .frame(height: captionHeight)
                        }
                        .frame(width: tileWidth)
                    }
                }
            }
        }
        .padding(outerPadding)
        .background(Color.black.opacity(0.05))
    }

    /// スライドを原寸で描画し、タイル枠へ縮小したサムネイル。
    private func thumbnail(of slide: any Slide, width: CGFloat, height: CGFloat) -> some View {
        AnyView(slide)
            .slideTheme(theme)
            .foregroundColor(.black)
            .background(.white)
            .frame(width: slideSize.width, height: slideSize.height)
            .scaleEffect(width / slideSize.width, anchor: .topLeading)
            .frame(width: width, height: height, alignment: .topLeading)
            .allowsHitTesting(false) // 一覧ではタップ等を無効化(デモ起動ボタンなどの誤爆防止)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(Color.gray.opacity(0.4), lineWidth: 1)
            }
    }
}

/// アプリ内でスクロールしながら見るための一覧View(SlideGridView のラッパー)。
public struct SlideListView: View {
    private let slides: [any Slide]
    private let listTextStyle: ListTextStyle
    private let columns: Int
    private let slideSize: CGSize

    private let tileSpacing: CGFloat = 20
    private let outerPadding: CGFloat = 20

    public init(
        slideIndexController: SlideIndexController,
        listTextStyle: ListTextStyle = .standard,
        columns: Int = 2,
        slideSize: CGSize = SlideSize.standard16_9
    ) {
        self.slides = slideIndexController.slides
        self.listTextStyle = listTextStyle
        self.columns = max(1, columns)
        self.slideSize = slideSize
    }

    public var body: some View {
        GeometryReader { proxy in
            let tileWidth = (proxy.size.width
                             - outerPadding * 2
                             - tileSpacing * CGFloat(columns - 1)) / CGFloat(columns)
            ScrollView {
                SlideGridView(
                    slides: slides,
                    listTextStyle: listTextStyle,
                    columns: columns,
                    tileWidth: max(tileWidth, 100),
                    slideSize: slideSize
                )
            }
        }
    }
}
