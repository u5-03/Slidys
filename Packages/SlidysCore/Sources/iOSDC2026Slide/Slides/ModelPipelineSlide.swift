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
        HeaderSlide("3Dモデルをアプリに表示するまでの流れ") {
            Item("腕装着型のカードデバイスは既存アセットが無いので、Blenderでゼロからモデリング", accessory: .number(1)) {
                Item("本体の円盤 / 5つのカードゾーンを持つブレード / デッキホルダー / ライフ表示部", accessory: .bullet)
            }
            Item("USDZとして書き出す", accessory: .number(2)) {
                Item("BlenderはZ-up、RealityKitはY-up。書き出し時に座標系が変換される(後でハマる)", accessory: .bullet)
            }
            Item("Swift PackageのリソースとしてUSDZを同梱し、RealityKitで読み込む", accessory: .number(3)) {
                Item("タップ判定などのインタラクションは読み込み後にコードで付与する", accessory: .bullet)
            }
        }
    }
}

#Preview {
    SlidePreview {
        ModelPipelineSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
