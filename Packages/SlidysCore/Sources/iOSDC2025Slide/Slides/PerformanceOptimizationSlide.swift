//
//  PerformanceOptimizationSlide.swift
//  iOSDC2025Slide
//
//  Created by Claude on 2025/01/21.
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct PerformanceOptimizationSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("手ジェスチャー検知のパフォーマンス最適化") {
            ScrollView {
                Item("trackingModeの使い分け", accessory: .number(1)) {
                    Item("初回検知結果を維持: .once(その位置・姿勢を保持)", accessory: .bullet)
                    Item("精度重視の判定: .continuous(細かい揺れなども含めて更新)", accessory: .bullet)
                    Item("UI追従の見た目: .predicted(体感遅延を低減)", accessory: .bullet)
                }

                Item("更新頻度の最適化", accessory: .number(2)) {
                    Item("手データ更新: 基本90Hz(visionOS2)", accessory: .bullet)
                    Item("ジェスチャー判定: 30-60Hzで十分", accessory: .bullet)
                }

                Item("追跡するEntity/Anchorの数を最小限にする", accessory: .number(3)) {
                    Item("追跡するEntity/Anchorが少ない方が、計算リソースが少なくて済む", accessory: .bullet)
                }
            }
        }
    }
}

#Preview {
    SlidePreview {
        PerformanceOptimizationSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
