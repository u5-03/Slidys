//
//  ModelPipelineSlide.swift
//  iOSDC2026Slide
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct ModelPipelineSlide: View {
    /// スピーカーノート(発表者用の原稿。ノートWindowに表示される)
    var script: String {
        "次にモデルがアプリに表示されるまでの流れです。\nまずは頑張ってBlenderでモデリングします。\nそしてそれをUSDZの形式で書き出します。\nその後、そのファイルをXcode内のReality Composer Pro用の.rkassetsというフォルダに置く。\nそうするとビルド時にXcodeのCLIツールのrealitytoolが.realityという最適化された形式にコンパイルし、RealityKitで読み込むことができます。タップ判定などの振る舞いはコードで付与します。"
    }

    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }
    @Environment(\.revealsAllPhases) private var revealsAllPhases
    @Environment(\.previewPhaseStep) private var previewPhaseStep
    @Phase private var phase: SlidePhase

    enum SlidePhase: Int, PhasedState {
        case initial, second, third, fourth
    }

    /// フェーズ表示の判定。通常は@Phaseの進行、スピーカーノートのプレビューでは
    /// previewPhaseStep(段階の直接指定)、一覧サムネイルでは全表示になる。
    private func shows(_ step: SlidePhase) -> Bool {
        if revealsAllPhases { return true }
        if let previewPhaseStep { return previewPhaseStep >= step.rawValue }
        return phase.isAfter(step)
    }

    var body: some View {
        HeaderSlide("3Dモデルがアプリに表示されるまで") {
            Item("Blenderでモデリング", keywords: ["Blender"], accessory: .number(1))
            if shows(.second) {
                Item("USDZに書き出し", keywords: ["USDZ"], accessory: .number(2))
            }
            if shows(.third) {
                Item("Xcode内のReality Composer Pro(以下RCP)用の.rkassetsフォルダに配置", keywords: [".rkassetsフォルダ"], accessory: .number(3))
            }
            if shows(.fourth) {
                Item("ビルドで.realityに変換され、RealityKitで読み込む", keywords: [".reality"], accessory: .number(4))
            }
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
