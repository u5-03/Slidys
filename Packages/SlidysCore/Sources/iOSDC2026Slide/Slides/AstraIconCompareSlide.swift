//
//  AstraIconCompareSlide.swift
//  iOSDC2026Slide
//
//  One more thingパート: Astraに作らせた3Dたい焼き(左)と、元ネタの自分のアイコン(右)を並べて見せる。
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct AstraIconCompareSlide: View {
    /// スピーカーノート(発表者用の原稿。ノートWindowに表示される)
    var script: String {
        "これは最初のOutputですが、それなりにいい感じかもしれません。"
    }

    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    /// 2枚の表示アスペクト比(生成画像802x514に合わせ、正方形のアイコンは上下をクロップする)
    private let imageAspectRatio: CGFloat = 802 / 514

    var body: some View {
        HeaderSlide("最初のOutput") {
            HStack(alignment: .top, spacing: 48) {
                compareImage(.astraTaiyakiIcon, label: "AIが生成")
                compareImage(.icon, label: "オリジナル")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    /// 2枚を同じ枠サイズ・同じアスペクト比で表示する(はみ出す分は中央基準でクロップ)
    private func compareImage(_ resource: ImageResource, label: String) -> some View {
        VStack(spacing: 24) {
            Text(label)
                .font(.system(size: 48, weight: .bold))
            Color.clear
                .aspectRatio(imageAspectRatio, contentMode: .fit)
                .overlay {
                    Image(resource)
                        .resizable()
                        .scaledToFill()
                }
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.15), lineWidth: 2)
                }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    SlidePreview {
        AstraIconCompareSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
