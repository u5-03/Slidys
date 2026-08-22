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
        HeaderSlide("デッキからカードを引く(ドロー)ジェスチャー") {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    Text("「触れた瞬間に引く」のではなく、2段階の判定にする")
                        .font(.regularFont)

                    CodeBlockView(
                        """
                        let fingersTouching = simd_distance(indexPos, middlePos) < threshold
                        let insideDeck = isPointInsideDeckVolume(midpoint) // デッキローカル座標でOBB判定

                        if isDeckDrawArmed {
                            if !fingersTouching || !insideDeck {
                                isDeckDrawArmed = false
                                performDeckDraw() // 指を離す or デッキから抜くとドロー発火
                            }
                        } else if fingersTouching && insideDeck {
                            isDeckDrawArmed = true // 指をくっつけてデッキ空間へ → 構え
                        }
                        """)

                    Text("カードの束から1枚スライドさせて抜く、あの動作の再現を目指した")
                        .font(.regularFont)
                        .padding(.top, 10)
                    Text("引いたカードは右手の指の間に追従(指の腹側にカード面・指先方向に上端)")
                        .font(.regularFont)
                }
            }
        }
    }
}

#Preview {
    SlidePreview {
        DeckDrawSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
