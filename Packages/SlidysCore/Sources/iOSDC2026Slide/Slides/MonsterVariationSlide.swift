//
//  MonsterVariationSlide.swift
//  iOSDC2026Slide
//
//  1モデル4バリエーションの説明 + 右側で具材切り替えのライブデモ。
//  (TaiyakiFocusView の fillingOnly モード: タップ・説明UIなし、ドラッグ回転と具材切り替えのみ)
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct MonsterVariationSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("モンスターは1モデルで4バリエーション") {
            HStack(alignment: .top, spacing: 60) {
                VStack(alignment: .leading, spacing: 44) {
                    Item("Blender製たい焼き。具材4種を同梱して、1つだけ表示する", keywords: ["1つだけ表示"], accessory: .number(1))
                    Item("具材の形ごと変更したいので、\nテクスチャ単位ではなく\nパーツ単位で切り替え", keywords: ["パーツ単位"], accessory: .number(2))
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                TaiyakiFocusView(mode: .fillingOnly, modelScale: 1.2)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .frame(width: 840)
                    .frame(maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    SlidePreview {
        MonsterVariationSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
