//
//  IssueBodySlide.swift
//  FlutterKaigi2026Slide
//
//  できあがる Issue 本文(Markdown)のイメージ。人が書く部分と機械が埋める部分を色分けする。
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct IssueBodySlide: View {
    /// スピーカーノート(発表者用の原稿。ノートWindowに表示される)
    var script: String {
        "できあがる Issue はこんな形です。白い部分が人が書くところで、タイトルと一言だけ。オレンジの部分は全部機械が埋めます。\n本文の末尾にはマーカーを付けていて、サーバ側の GitHub Actions がこれを見てアプリ起票の Issue だと判別します。"
    }

    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    private struct Line: Identifiable {
        let id = UUID()
        let text: String
        let auto: Bool
    }

    private let lines: [Line] = [
        .init(text: "## 概要", auto: false),
        .init(text: "カウントボタンを連打すると表示が1つ飛ぶ", auto: false),
        .init(text: "", auto: false),
        .init(text: "## 対象 UI 要素", auto: true),
        .init(text: "`home.counter.button`", auto: true),
        .init(text: "", auto: true),
        .init(text: "## Environment", auto: true),
        .init(text: "- App version: 1.0.0 (12)  - Device: iPhone 17 Pro, iOS 26.0", auto: true),
        .init(text: "- Locale: ja_JP  - Captured at: 2026-10-29T10:12:03Z", auto: true),
        .init(text: "", auto: true),
        .init(text: "## 添付", auto: true),
        .init(text: "screenshot.png / video.mp4 / view-hierarchy.txt / logs.txt / stack-trace.txt", auto: true),
        .init(text: "", auto: true),
        .init(text: "<!-- runtime-feedback:v1 -->", auto: true),
    ]

    var body: some View {
        HeaderSlide(loc: "できあがるIssue") {
            HStack(alignment: .top, spacing: 48) {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(lines) { line in
                        Text(line.text.isEmpty ? " " : line.text)
                            .font(.system(size: 32, weight: line.text.hasPrefix("##") ? .bold : .regular, design: .monospaced))
                            .foregroundStyle(line.auto ? Color.strokeColor : .defaultForegroundColor)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                    }
                }
                .padding(36)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.black.opacity(0.35))
                )

                VStack(alignment: .leading, spacing: 40) {
                    legend(color: .defaultForegroundColor, text: "人が書く\n(タイトルと一言)")
                    legend(color: .strokeColor, text: "機械が埋める\n(収集・添付・マーカー)")
                }
                .frame(width: 520, alignment: .leading)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func legend(color: Color, text: String) -> some View {
        HStack(alignment: .top, spacing: 20) {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(width: 36, height: 36)
                .padding(.top, 8)
            Text(text)
                .font(.system(size: 38, weight: .bold))
                .foregroundStyle(color)
                .lineLimit(2)
                .minimumScaleFactor(0.6)
        }
    }
}

#Preview {
    SlidePreview {
        IssueBodySlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
