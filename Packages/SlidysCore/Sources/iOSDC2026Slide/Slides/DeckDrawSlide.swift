//
//  DeckDrawSlide.swift
//  iOSDC2026Slide
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct DeckDrawSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("デッキからカードを引く(ドロー)") {
            Item("伸ばした人差し指+中指でデッキに触れて、抜く動作で発火する", keywords: [], accessory: .number(1))
            Item("引いたカードは右手の指の間に追従", keywords: [], accessory: .number(2))

            // ドロー動作の実機シーン(下に横長で配置)
            Image(.deckDrawCapture)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.15), lineWidth: 2)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}

#Preview {
    SlidePreview {
        DeckDrawSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
