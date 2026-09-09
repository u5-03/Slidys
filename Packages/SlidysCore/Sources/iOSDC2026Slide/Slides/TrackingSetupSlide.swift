//
//  TrackingSetupSlide.swift
//  iOSDC2026Slide
//
//  Hand Gesture章の導入2枚。
//  1枚目: 去年(iOSDC2025)の発表のアピール(プロポーザル画像)
//  2枚目: 今回使っているジェスチャーの一覧
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct TrackingSetupSlide: View {
    /// スピーカーノート(発表者用の原稿。ノートWindowに表示される)
    var script: String {
        "ジェスチャー検知の土台は、去年のiOSDC2025の発表で作ったHandGestureKitをそのまま使っています。\n去年は手話ジェスチャーの検知と翻訳というテーマで、話しました。この写真はただピースサインをしているのではなく、ピースサインの形を検知できるかのデモの様子を激写されただけで、決してテンションが上がっていたわけではないです。"
    }

    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("土台は去年のHandGestureKitそのまま") {
            // 去年のプロポーザル画像と、実際の登壇写真を横並びで
            HStack(spacing: 48) {
                appealImage(.proposal2025)
                appealImage(.iosdcDemo)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    /// プロポーザル画像(1200×630)と同じアスペクト比の枠に入れ、
    /// 縦長の写真は上下をセンタークロップして高さを揃える
    private func appealImage(_ resource: ImageResource) -> some View {
        Color.clear
            .aspectRatio(1200.0 / 630.0, contentMode: .fit)
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
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

@Slide
struct TrackingGestureListSlide: View {
    /// スピーカーノート(発表者用の原稿。ノートWindowに表示される)
    var script: String {
        "検知の基礎はHandGestureKitで、関節ごとのAnchor情報から、指の形や距離の条件に一致しているかどうかをクエリのように指定して判定できるようにしたライブラリです。ここは去年と同じです。\n今回のアプリに載せたのは、ディスクを手首に装着させるトラッキングと、3本指の手札・ドローなどのジェスチャーです。\nディスクは手首の座標にロケーターの位置を合わせて配置しています。"
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
        HeaderSlide("ジェスチャーやトラッキングまわりの構成") {
            Item("検知の基礎はHandGestureKit(去年の発表)", keywords: ["HandGestureKit"], accessory: .number(1))
            if shows(.second) {
                Item("手首装着トラッキング + ジェスチャー3つ", keywords: [], accessory: .number(2))
            }
            if shows(.third) {
                Item("ディスクは手首の座標に合わせて配置", keywords: [], accessory: .number(3))
            }
        }
    }
}

#Preview("去年のアピール") {
    SlidePreview {
        TrackingSetupSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}

#Preview("ジェスチャー一覧") {
    SlidePreview {
        TrackingGestureListSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
