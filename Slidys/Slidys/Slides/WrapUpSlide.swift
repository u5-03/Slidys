//
//  WrapUpSlide.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/11/09.
//

import SwiftUI
import SlideKit
import SlidysCore

@Slide
struct WrapUpSlide: View {
    var body: some View {
        HeaderSlide("まとめ") {
            Item("CustomMultiChildLayoutは、既存のWidgetやContainerでは表現が難しいデザインの時に活躍する強い味方", accessory: .number(1))
            Item("パフォーマンスを考慮して使うことが必要そう(特にスクロールが必要な場合)", accessory: .number(2))
            Item("学習コストが高く、運用にも明確なルールの設定や周知などが必要になるので、RowやColumn、Stackの基本的な使い方で実装できない場合の最終手段として使うのがよい", accessory: .number(3)) {
                Item("乱用は注意！", accessory: .number(1))
            }
        }
    }
}

#Preview {
    SlidePreview {
        WrapUpSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
