//
//  PossibilitiesSlide.swift
//  iOSDC2025Slide
//
//  Created by Claude on 2025/01/21.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct PossibilitiesSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }
    
    var body: some View {
        HeaderSlide("それでも広がる可能性") {
            ScrollView {
                Item("基本的な手話単語の認識は可能！", accessory: .number(1)) {
                    Item("✅ 日常的な挨拶（ありがとう）", accessory: .bullet)
                    Item("✅ 数字や簡単な単語", accessory: .bullet)
                    Item("✅ Yes/Noなどの基本的な応答", accessory: .bullet)
                }
                Item("アクセシビリティ向上への第一歩", accessory: .number(3)) {
                    Item("✅ 聴覚障害者と健聴者のコミュニケーション支援", accessory: .bullet)
                    Item("✅ 緊急時の簡単な意思疎通", accessory: .bullet)
                    Item("✅ 手話への関心と理解の促進", accessory: .bullet)
                }
                Item("今後の技術発展への期待", accessory: .number(4)) {
                    Item("✅ ハードウェアの進化による精度向上", accessory: .bullet)
                    Item("✅ 機械学習・AIとの組み合わせ?", accessory: .bullet)
                    Item("✅ 表情の重要性: EyeSightにより、表情が分かりやすい", accessory: .bullet)
                    Item("✅ より多くの手話表現への対応", accessory: .bullet)
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
