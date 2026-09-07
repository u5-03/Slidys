//
//  BlenderModelingSlide.swift
//  iOSDC2026Slide
//
//  Blenderでのモデリング画面(左: ディスク / 右: たい焼き)を横並びで見せる。
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct BlenderModelingSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("Blenderでのモデリング") {
            HStack(spacing: 48) {
                captureImage(.blenderDiskModeling)
                captureImage(.blenderTaiyakiModeling)
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
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.15), lineWidth: 2)
            }
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    SlidePreview {
        BlenderModelingSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
