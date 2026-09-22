//
//  ReferenceSlide.swift
//  FlutterKaigi2026Slide
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct ReferenceSlide: View {
    /// スピーカーノート(発表者用の原稿。ノートWindowに表示される)
    var script: String {
        "こちら参考情報です。"
    }

    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("参考情報") {
            // 通常のリスト(60pt)だと長いタイトルが収まらないため、専用の少し小さめのレイアウトにする
            VStack(alignment: .leading, spacing: 44) {
                referenceRow(
                    number: 1,
                    title: "Inside Flutter - Flutter Docs(Widget / Element / RenderObject のツリー)",
                    url: "https://docs.flutter.dev/resources/inside-flutter"
                )
                referenceRow(
                    number: 2,
                    title: "RenderRepaintBoundary.toImageSync - Flutter API",
                    url: "https://api.flutter.dev/flutter/rendering/RenderRepaintBoundary/toImageSync.html"
                )
                referenceRow(
                    number: 3,
                    title: "SemanticsProperties.identifier - Flutter API",
                    url: "https://api.flutter.dev/flutter/semantics/SemanticsProperties/identifier.html"
                )
                referenceRow(
                    number: 4,
                    title: "AVAssetWriter - Apple Developer Documentation",
                    url: "https://developer.apple.com/documentation/avfoundation/avassetwriter"
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    /// タイトル + URLの1セット。Text(verbatim:)でMarkdown解釈を防ぐ
    private func referenceRow(number: Int, title: String, url: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(verbatim: "\(number). \(title)")
                .font(.system(size: 44, weight: .semibold))
                .foregroundStyle(.defaultForegroundColor)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(verbatim: url)
                .font(.system(size: 32, weight: .regular))
                .foregroundStyle(.gray)
                .padding(.leading, 52)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    SlidePreview {
        ReferenceSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
