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
                    Item("具材4種を別パーツとして全部同梱(Blender製たい焼き)", accessory: .number(1))
                    Item("実行時はカードに対応するパーツだけ表示", accessory: .number(2))
                    Item("形ごと変えたい → パーツ切り替え / 絵だけ → テクスチャ差し替え", accessory: .number(3))
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                TaiyakiFocusView(mode: .fillingOnly)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .frame(width: 760)
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
