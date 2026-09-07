//
//  SummonSequenceSlide.swift
//  iOSDC2026Slide
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct SummonSequenceSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("召喚シーケンスの全体像") {
            HStack(alignment: .top, spacing: 60) {
                VStack(alignment: .leading, spacing: 44) {
                    Item("ディスク上: 置いたゾーンから盤面全体へ光のライン", keywords: [], accessory: .number(1))
                    Item("フィールド: カードが出現して上昇 + 足元で放射状の光のバースト", keywords: [], accessory: .number(2))
                    Item("1秒後、光の中からモンスターがフェードイン + せり上がり", keywords: [], accessory: .number(3))
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // 上: ラインエフェクト / 下: モンスター出現の実機シーン(同じ枠サイズで縦に並べる)
                VStack(spacing: 24) {
                    captureImage(.summonLineCapture)
                    captureImage(.summonTaiyakiCapture)
                }
                .frame(width: 620)
                .frame(maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    /// 2枚を同じ枠サイズ・同じアスペクト比(16:10)で表示する(はみ出す分は中央基準でクロップ)
    private func captureImage(_ resource: ImageResource) -> some View {
        Color.clear
            .aspectRatio(16.0 / 10.0, contentMode: .fit)
            .overlay {
                Image(resource)
                    .resizable()
                    .scaledToFill()
            }
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.15), lineWidth: 2)
            }
    }
}

#Preview {
    SlidePreview {
        SummonSequenceSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
