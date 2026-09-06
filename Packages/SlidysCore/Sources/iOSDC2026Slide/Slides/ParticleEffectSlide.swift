//
//  ParticleEffectSlide.swift
//  iOSDC2026Slide
//
//  召喚バーストの説明 + 右側に実機キャプチャ(白飛びドームとスパークル)。
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
        HeaderSlide("召喚バーストはRCPで作ったパーティクル") {
            HStack(alignment: .top, spacing: 60) {
                VStack(alignment: .leading, spacing: 44) {
                    Item("線・スパークル・光の球の3エミッタ。見た目はRCPのGUIでプレビューしながら調整", keywords: [], accessory: .number(1))
                    Item("光をにじませる機能(ブルーム)が無いので、\nぼけた光の粒をたくさん重ねて、\n中心を真っ白にして光らせる", keywords: ["真っ白"], accessory: .number(2))
                    Item("光の球は見えない壁で下半分を隠して上だけ見える半球ドームにする", keywords: ["見えない壁"], accessory: .number(3))
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(.summonBurstCapture)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.15), lineWidth: 2)
                    }
                    .frame(width: 700)
                    .frame(maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    SlidePreview {
        ParticleEffectSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
