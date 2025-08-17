//
//  LimitationsSlide.swift
//  iOSDC2025Slide
//
//  Created by Claude on 2025/01/09.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct LimitationsSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }
    
    var body: some View {
        HeaderSlide("Apple Vision Proでの手話検知の限界") {
            ScrollView {
                Item("カメラの検知範囲の制限", accessory: .number(1)) {
                    Item("❌ 体の後ろや横の手は検知不可", accessory: .bullet)
                    Item("❌ 顔の近くや頭の後ろも死角", accessory: .bullet)
                    Item("❌ 手が重なると正確な検知が困難", accessory: .bullet)
                }
                Item("複雑な手の形状", accessory: .number(2)) {
                    Item("❌ 指が絡み合うような形は誤認識しやすい", accessory: .bullet)
                    Item("❌ 細かい指の角度の違いを区別できない", accessory: .bullet)
                    Item("❌ 手の微妙な傾きや回転の検出精度", accessory: .bullet)
                }
                Item("手話特有の要素", accessory: .number(3)) {
                    Item("❌ 表情による意味の変化は検知不可", accessory: .bullet)
                    Item("❌ 動きの速度や強弱の認識が困難", accessory: .bullet)
                    Item("❌ 口の形（口型）との組み合わせ", accessory: .bullet)
                }
                Item("技術的な制約", accessory: .number(4)) {
                    Item("❌ 両手の同時トラッキング精度", accessory: .bullet)
                    Item("❌ 連続的な動作の認識", accessory: .bullet)
                    Item("❌ 個人差（手の大きさ・柔軟性）への対応", accessory: .bullet)
                }
                Item("それでも...", accessory: .number(5)) {
                    Item("✅ 基本的な手話単語の認識は可能！", accessory: .bullet)
                    Item("✅ 学習ツールとしての可能性", accessory: .bullet)
                    Item("✅ アクセシビリティ向上への第一歩", accessory: .bullet)
                }
            }
        }
    }
}

#Preview {
    SlidePreview {
        LimitationsSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}

