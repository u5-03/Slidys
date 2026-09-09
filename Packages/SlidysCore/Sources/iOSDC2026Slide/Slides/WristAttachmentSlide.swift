//
//  WristAttachmentSlide.swift
//  iOSDC2026Slide
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct WristAttachmentSlide: View {
    /// スピーカーノート(発表者用の原稿。ノートWindowに表示される)
    var script: String {
        "手首アンカーの子にすると、トラッキングが途切れた瞬間にディスクが消えたり暴れたりします。手首は視界の端に行きがちなので、ロストは頻繁に起きます。\nそこで子にはせず、ワールド空間に置いたディスクが毎フレーム手首の姿勢を「追いかける」方式にしました。ロスト中は最後の姿勢でその場に留まります。\nさらに毎フレーム目標に35%だけ近づけるローパスフィルタで、関節推定のブレを吸収しています。"
    }

    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }
    @Environment(\.revealsAllPhases) private var revealsAllPhases
    @Environment(\.previewPhaseStep) private var previewPhaseStep
    @Phase private var phase: SlidePhase

    enum SlidePhase: Int, PhasedState {
        case initial, second, third
    }

    /// フェーズ表示の判定。通常は@Phaseの進行、スピーカーノートのプレビューでは
    /// previewPhaseStep(段階の直接指定)、一覧サムネイルでは全表示になる。
    private func shows(_ step: SlidePhase) -> Bool {
        if revealsAllPhases { return true }
        if let previewPhaseStep { return previewPhaseStep >= step.rawValue }
        return phase.isAfter(step)
    }

    var body: some View {
        HeaderSlide("ディスクを手首に「安定して」装着する") {
            Item("アンカーの子にすると、ロストで消える・暴れる", keywords: ["消える・暴れる"], accessory: .number(1))
            if shows(.second) {
                Item("子にせず、毎フレーム手首を「追いかける」", keywords: ["追いかける"], accessory: .number(2))
            }
            if shows(.third) {
                Item("毎フレーム35%ずつ寄せてブレを吸収", keywords: ["35%"], accessory: .number(3))
            }
        }
    }
}

#Preview {
    SlidePreview {
        WristAttachmentSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
