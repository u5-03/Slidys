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

    /// 2枚を同じ枠サイズ(等分)で、アスペクト比を保ったまま表示する
    private func captureImage(_ resource: ImageResource) -> some View {
        Image(resource)
            .resizable()
            .scaledToFit()
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.15), lineWidth: 2)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    SlidePreview {
        BlenderModelingSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
