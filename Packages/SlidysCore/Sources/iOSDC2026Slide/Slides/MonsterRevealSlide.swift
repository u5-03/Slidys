//
//  MonsterRevealSlide.swift
//  iOSDC2026Slide
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct MonsterRevealSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("「光の中から現れる」モンスターの出現") {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    Text("最終位置より下に透明状態で生成 → フェードインしながらせり上がらせる")
                        .font(.regularFont)

                    CodeBlockView(
                        """
                        container.components.set(OpacityComponent(opacity: 0))
                        container.move(to: goal, relativeTo: container.parent,
                                       duration: duration, timingFunction: .easeOut)
                        let fadeIn = FromToByAnimation<Float>(
                            from: 0, to: 1, duration: duration,
                            timing: .easeOut, bindTarget: .opacity
                        )
                        if let resource = try? AnimationResource.generate(with: fadeIn) {
                            container.playAnimation(resource)
                        }
                        """)

                    Text("パーティクルのピークに上昇を重ねると、出現の瞬間が粒に紛れて「いつの間にかそこにいる」ように見える")
                        .font(.regularFont)
                        .padding(.top, 10)
                    Text("派手なエフェクト単体より、タイミングの重ね方が体験の説得力に効く")
                        .font(.regularFont)
                }
            }
        }
    }
}

#Preview {
    SlidePreview {
        MonsterRevealSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
