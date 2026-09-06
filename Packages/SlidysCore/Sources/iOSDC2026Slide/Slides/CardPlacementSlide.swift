//
//  CardPlacementSlide.swift
//  iOSDC2026Slide
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct CardPlacementSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("カード配置: 配置先の判定") {
            HStack(alignment: .top, spacing: 60) {
                VStack(alignment: .leading, spacing: 44) {
                    Item("標準の視線フォーカス + タップ or カードを召喚エリアに重ねることで配置", keywords: [], accessory: .number(1))
                    Item("どのスロットかは自作Componentを持つかどうかで判定(Entity名での文字列比較はしない)", keywords: ["Component"], accessory: .number(2))
                    Item("持っているカードの種類で、置けるスロットだけハイライト", keywords: ["置けるスロットだけ"], accessory: .number(3))
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(.blenderDiskPlacement)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.15), lineWidth: 2)
                    }
                    .frame(width: 860)
                    .frame(maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    SlidePreview {
        CardPlacementSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
