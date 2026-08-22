//
//  MonsterVariationSlide.swift
//  iOSDC2026Slide
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
        HeaderSlide("モンスターは1モデルでバリエーションを作る") {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    Text("召喚するモンスターはBlender製「たい焼き」モデル")
                        .font(.regularFont)
                    Text("1つのUSDZに具材ノード4種(あんこ/クリーム/抹茶/チョコ)を全部入れておき、カードに対応するノードだけ表示する")
                        .font(.regularFont)

                    CodeBlockView(
                        """
                        let monster = try await Entity(named: "Taiyaki", in: sugiyBundle)
                        for name in fillingNames {
                            // カードの具材に対応するノードだけを有効化する
                            monster.findEntity(named: name)?.isEnabled = (name == flavor.fillingNodeName)
                        }
                        """)

                    Text("モデル差し替えよりも、ロードが1回で済む + Blender側の管理が1ファイルにまとまる")
                        .font(.regularFont)
                        .padding(.top, 10)
                }
            }
        }
    }
}

#Preview {
    SlidePreview {
        MonsterVariationSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
