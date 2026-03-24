//
//  PossibilitiesSlide.swift
//  iOSDC2025Slide
//
//  Created by Claude on 2025/01/21.
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct PossibilitiesSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("それでも広がる可能性") {
            ScrollView {
                Item("基本的な手話単語の認識は可能！", accessory: .number(1)) {
                    Item("✅ 定型的な表現(ありがとう)", accessory: .bullet)
                    Item("✅ 数字や簡単な単語", accessory: .bullet)
                }
                Item("健聴者が手話の世界に触れるきっかけづくり", accessory: .number(2)) {
                    Item("✅ 手話を知らない人でも気軽に体験できる入口に", accessory: .bullet)
                    Item("✅ 聴覚障害者とのコミュニケーション方法を学ぶ機会の提供", accessory: .bullet)
                    Item("✅ 日常で使える簡単な手話から始められる", accessory: .bullet)
                    Item("✅ 緊急時の意思疎通手段としても活用", accessory: .bullet)
                }
                Item("今後の技術発展への期待", accessory: .number(3)) {
                    Item("✅ ハードウェアやOSの進化による精度向上", accessory: .bullet)
                    Item("✅ 機械学習・AIとの組み合わせ?", accessory: .bullet)
                }
            }
        }
    }
}

#Preview {
    SlidePreview {
        PossibilitiesSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
