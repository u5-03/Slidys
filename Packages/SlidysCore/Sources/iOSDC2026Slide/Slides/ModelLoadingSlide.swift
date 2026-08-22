//
//  ModelLoadingSlide.swift
//  iOSDC2026Slide
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct ModelLoadingSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("USDZの読み込みとタップ判定の付与") {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    Text("1. パッケージ同梱のUSDZをEntityとして読み込む")
                        .font(.regularFont)

                    CodeBlockView(
                        """
                        let model = try await Entity(named: modelName, in: Bundle.module)
                        """)

                    Text("2. ノード名で対象を探し、タップ判定コンポーネントをセット")
                        .font(.regularFont)
                        .padding(.top, 10)

                    CodeBlockView(
                        """
                        guard let entity = model.findEntity(named: name) else { continue }
                        let bounds = entity.visualBounds(relativeTo: entity)
                        // 薄いメッシュでも押せるよう最低サイズを確保 + 判定箱をboundsの中心へ寄せる
                        entity.components.set(CollisionComponent(
                            shapes: [.generateBox(size: size).offsetBy(translation: bounds.center)],
                            isStatic: true, filter: .default
                        ))
                        entity.components.set(InputTargetComponent())
                        entity.components.set(HoverEffectComponent())
                        """)

                    Text("ハマりどころ: メッシュ原点と見た目の中心はズレる / 薄いメッシュは視線・タップがほぼ通らない")
                        .font(.regularFont)
                        .padding(.top, 10)
                }
            }
        }
    }
}

#Preview {
    SlidePreview {
        ModelLoadingSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
