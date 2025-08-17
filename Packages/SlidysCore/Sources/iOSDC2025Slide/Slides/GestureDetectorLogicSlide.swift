//
//  GestureDetectorLogicSlide.swift
//  iOSDC2025Slide
//
//  Created by Claude on 2025/01/09.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct GestureDetectorLogicSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }
    
    var body: some View {
        HeaderSlide("UnifiedGestureDetectorの処理ロジック") {
            ScrollView {
                Item("ジェスチャー検出の流れ", accessory: .number(1)) {
                    Item("優先度順にソートされたジェスチャーリストを保持", accessory: .bullet)
                    Item("上位から順番にマッチング判定", accessory: .bullet)
                    Item("最初にマッチしたジェスチャーを返す", accessory: .bullet)
                }
                Item("判定条件の種類", accessory: .number(2)) {
                    Item("指の曲げ伸ばし状態（isExtended/isCurled）", accessory: .bullet)
                    Item("手のひらの向き（palmDirection）", accessory: .bullet)
                    Item("関節間の角度（angleWithParent）", accessory: .bullet)
                    Item("関節間の距離（jointToJointDistance）", accessory: .bullet)
                }
                Item("カテゴリ別の高速検索", accessory: .number(3)) {
                    Item("片手ジェスチャー / 両手ジェスチャー", accessory: .bullet)
                    Item("静的ジェスチャー / 動的ジェスチャー", accessory: .bullet)
                    Item("手話ジェスチャー専用カテゴリ", accessory: .bullet)
                }
                Item("パフォーマンス最適化", accessory: .number(4)) {
                    Item("インデックスによる検索の高速化", accessory: .bullet)
                    Item("不要な判定のスキップ", accessory: .bullet)
                    Item("統計情報による検出精度の改善", accessory: .bullet)
                }
            }
        }
    }
}

#Preview {
    SlidePreview {
        GestureDetectorLogicSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
