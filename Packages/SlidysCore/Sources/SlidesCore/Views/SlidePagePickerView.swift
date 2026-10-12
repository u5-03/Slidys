//
//  SlidePagePickerView.swift
//  SlidesCore
//
//  発表者メニューの「ページを選ぶ」で出す、サムネイルの一覧。タップしたページへ直接移動する。
//

import SlideKit
import SwiftUI

struct SlidePagePickerView: View {
    @ObservedObject var slideIndexController: SlideIndexController
    let listTextStyle: ListTextStyle
    @Environment(\.dismiss) private var dismiss

    private let columns = [GridItem(.adaptive(minimum: 220, maximum: 360), spacing: 16)]

    /// 一覧ではページ番号を自前で出すので、スライド内の番号は消す
    private var thumbnailTheme: CustomSlideTheme {
        CustomSlideTheme(showSlideIndex: false, listTextStyle: listTextStyle)
    }

    var body: some View {
        NavigationStack {
            ScrollViewReader { scrollProxy in
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(slideIndexController.slides.indices, id: \.self) { index in
                            Button {
                                slideIndexController.move(to: index)
                                dismiss()
                            } label: {
                                tile(index: index)
                            }
                            .buttonStyle(.plain)
                            .id(index)
                        }
                    }
                    .padding(20)
                }
                .onAppear {
                    scrollProxy.scrollTo(slideIndexController.currentIndex, anchor: .center)
                }
            }
            .navigationTitle("ページを選ぶ")
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
        // サムネイルの文言も、いまの表示言語に合わせる
        .followsSlideLanguage()
    }

    private func tile(index: Int) -> some View {
        let isCurrent = index == slideIndexController.currentIndex
        return VStack(alignment: .leading, spacing: 6) {
            // 幅はグリッドのセルに合わせる(原寸 1920 を縮小して描く)
            GeometryReader { proxy in
                SlideThumbnailView(
                    slide: slideIndexController.slides[index],
                    theme: thumbnailTheme,
                    width: proxy.size.width
                )
            }
            .aspectRatio(SlideSize.standard16_9.width / SlideSize.standard16_9.height, contentMode: .fit)
            .overlay {
                if isCurrent {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(Color.accentColor, lineWidth: 4)
                }
            }
            Text("\(index + 1) / \(slideIndexController.slides.count)")
                .font(.system(size: 15, weight: isCurrent ? .bold : .regular, design: .monospaced))
                .foregroundStyle(isCurrent ? Color.accentColor : .secondary)
        }
        .contentShape(Rectangle())
    }
}
