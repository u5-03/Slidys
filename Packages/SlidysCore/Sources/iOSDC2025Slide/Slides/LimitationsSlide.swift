//
//  LimitationsSlide.swift
//  iOSDC2025Slide
//
//  Created by Claude on 2025/01/09.
//

import SlideKit
import SlidesCore
import SwiftUI

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
                    Item("❌ 手の微妙な傾きや回転の検出精度", accessory: .bullet)
                }
                Item("手話特有の要素", accessory: .number(3)) {
                    Item("❌ 表情による意味の変化の検知は困難", accessory: .bullet)
                    Item("❌ 動きの速度や強弱の認識が困難", accessory: .bullet)
                }
                Item("技術的な制約", accessory: .number(4)) {
                    Item("❌ 認識パターンの登録が大変", accessory: .bullet)
                    Item("❌ パフォーマンスとのバランス", accessory: .bullet)
                    Item("❌ 個人差(手の大きさ・柔軟性)への対応", accessory: .bullet)
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
