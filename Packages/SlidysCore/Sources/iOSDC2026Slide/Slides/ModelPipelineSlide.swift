//
//  ModelPipelineSlide.swift
//  iOSDC2026Slide
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct ModelPipelineSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("3Dモデルがアプリに表示されるまで") {
            Item("Blenderでゼロからモデリング", accessory: .number(1))
            Item("USDZに書き出す", accessory: .number(2))
            Item("Reality Composer Pro(以下RCP)のパッケージ形式(.rkassets)に置く → ビルド時に.realityへ", accessory: .number(3))
            Item("RealityKitで読み込む。タップ判定などはコードで付与", accessory: .number(4))
        }
    }
}

#Preview {
    SlidePreview {
        ModelPipelineSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
