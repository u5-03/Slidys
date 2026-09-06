//
//  ReferenceSlide.swift
//  iOSDC2026Slide
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct ReferenceSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("参考情報") {
            // 通常のリスト(60pt)だと長いタイトルが収まらないため、専用の少し小さめのレイアウトにする
            VStack(alignment: .leading, spacing: 48) {
                referenceRow(
                    number: 1,
                    title: "Meet Reality Composer Pro - WWDC23",
                    url: "https://developer.apple.com/videos/play/wwdc2023/10083/"
                )
                referenceRow(
                    number: 2,
                    title: "Create enhanced spatial computing experiences with ARKit - WWDC24",
                    url: "https://developer.apple.com/videos/play/wwdc2024/10100/"
                )
                referenceRow(
                    number: 3,
                    title: "【iOSDC2025】手話ジェスチャーの検知と翻訳~ハンドトラッキングの可能性と限界~",
                    url: "https://ulog.sugiy.com/iosdc2025-vision-hand-gesture-tracking/"
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    /// タイトル + URLの1セット。Text(verbatim:)で「~〜~」がMarkdownの取り消し線に解釈されるのを防ぐ
    private func referenceRow(number: Int, title: String, url: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(verbatim: "\(number). \(title)")
                .font(.system(size: 44, weight: .semibold))
                .foregroundStyle(.defaultForegroundColor)
            Text(verbatim: url)
                .font(.system(size: 34, weight: .regular))
                .foregroundStyle(.gray)
                .padding(.leading, 52)
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
