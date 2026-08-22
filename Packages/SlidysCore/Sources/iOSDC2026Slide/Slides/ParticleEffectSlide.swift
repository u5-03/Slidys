//
//  ParticleEffectSlide.swift
//  iOSDC2026Slide
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct ParticleEffectSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("ParticleEmitterComponentで作る召喚の光") {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    Text("役割の異なる3つのエミッター + PointLightを重ねる")
                        .font(.regularFont)
                    Text("① 足元のburst ② 円筒ボリュームに漂う「星の霧」 ③ stretchFactorで線状に伸ばす光の筋")
                        .font(.regularFont)

                    Text("visionOSはポストプロセスのブルームが使えない → 加算ブレンドの重なりで擬似グロー")
                        .font(.regularFont)
                        .padding(.top, 10)
                    Text("丸いデフォルトスプライトでは「白い点の飛散」にしか見えない → 星型スプライトをCoreGraphicsで動的生成")
                        .font(.regularFont)

                    CodeBlockView(
                        """
                        emitter.mainEmitter.image = glint            // 星型スプライト
                        emitter.mainEmitter.blendMode = .additive    // 重なるほど白飛び = 擬似ブルーム
                        emitter.mainEmitter.sizeMultiplierAtEndOfLifespan = 0.0 // 点に収縮して消える
                        """)

                    Text("注意: ParticleEmitterComponentは値型。burst()やbirthRate変更後はcomponents.set()で書き戻さないと何も起きない")
                        .font(.regularFont)
                        .padding(.top, 10)

                    CodeBlockView(
                        """
                        guard var emitter = entity.components[ParticleEmitterComponent.self] else { return }
                        emitter.burst()
                        entity.components.set(emitter) // ← 書き戻しが必須
                        """)
                }
            }
        }
    }
}

#Preview {
    SlidePreview {
        ParticleEffectSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
