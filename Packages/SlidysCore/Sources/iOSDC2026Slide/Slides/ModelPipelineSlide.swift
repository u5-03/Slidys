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
            Item("Blenderでゼロからモデリング", keywords: ["Blender"], accessory: .number(1))
            Item("USDZに書き出す", keywords: ["USDZ"], accessory: .number(2))
            Item("Reality Composer Pro(以下RCP)の.rkassetsフォルダに配置。ビルド時にXcodeのCLIツールが.realityへ変換", keywords: [".rkassetsフォルダ"], accessory: .number(3))
            Item("RealityKitでそのファイルを読み込む。タップ判定などはコードで付与", keywords: ["コードで付与"], accessory: .number(4))
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
