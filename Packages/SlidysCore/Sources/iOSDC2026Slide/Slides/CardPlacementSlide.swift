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
        HeaderSlide("カード配置: タップの「意味」をComponentで解決する") {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    Text("配置はvisionOS標準の視線 + タップ(SpatialTapGesture)")
                        .font(.regularFont)
                    Text("タップされたEntityが何であるかは、名前文字列ではなく自作Componentで判定")
                        .font(.regularFont)

                    CodeBlockView(
                        """
                        if let slotIdx = target?.components[DiskSlotIndexComponent.self]?.index {
                            sessionStore.placeSelectedCardToDiskSlot(index: slotIdx)
                        } else if let location = target?.components[PlacedCardLocationComponent.self] {
                            sessionStore.tappedPlacedCardContext = mapToContext(location.location)
                        } else if let cardId = target?.components[CardIdentityComponent.self]?.id {
                            sessionStore.selectHandCard(id: cardId)
                        }
                        """)

                    Text("タップイベントはコライダーを持つ末端Entityが返るので、祖先へ遡ってComponentを探す")
                        .font(.regularFont)
                        .padding(.top, 10)
                    Text("ECSのComponentを「Entityへの意味づけタグ」として使うパターンはかなり便利")
                        .font(.regularFont)
                }
            }
        }
    }
}

#Preview {
    SlidePreview {
        CardPlacementSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
