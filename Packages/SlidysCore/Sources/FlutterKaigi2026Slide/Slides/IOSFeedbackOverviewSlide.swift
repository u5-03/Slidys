//
//  IOSFeedbackOverviewSlide.swift
//  FlutterKaigi2026Slide
//
//  「いまの一般的なバグ起票の流れ」と「アプリ内バグ起票の流れ」を上下に並べて比較する。
//  起点(バグや改善点を検知)は同じで、アプリ内起票では 起票時の情報入力が自動になり、
//  起票後に GitHub Actions が下調べ・振り分けまでやる、という差を見せる。
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct IOSFeedbackOverviewSlide: View, PhasedScriptProviding {
    /// スピーカーノート(1 段目: いまの一般的な流れ / 2 段目: アプリ内バグ起票)
    var scriptSegments: [String] {
        [
        "まずは起票の流れを確認しましょう。これが一般的な流れです。動画やスクショを用意して、再現手順や環境情報を手で書いて起票する。ここが大変です。",
        "それに対して、私がいるプロジェクトで運用しているアプリ内バグ起票がこちらです。動画はアプリが撮っていて、環境情報は自動入力され、起票後に GitHub Actions がValidationや下調べを行います。\nこのアプリ内の処理を Flutter で作れるのか、が今日の話です。",
        ]
    }

    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }
    @Environment(\.revealsAllPhases) private var revealsAllPhases
    @Environment(\.previewPhaseStep) private var previewPhaseStep
    @Phase private var phase: SlidePhase

    enum SlidePhase: Int, PhasedState {
        case initial, second
    }

    private func shows(_ step: SlidePhase) -> Bool {
        if revealsAllPhases { return true }
        if let previewPhaseStep { return previewPhaseStep >= step.rawValue }
        return phase.isAfter(step)
    }

    private struct Step {
        let symbol: String
        let title: String
        let detail: String
        let highlighted: Bool
    }

    private let currentFlow: [Step] = [
        .init(symbol: "exclamationmark.bubble", title: "バグや改善点を検知", detail: "", highlighted: false),
        .init(symbol: "photo.on.rectangle", title: "動画やスクショの用意", detail: "自分で撮る", highlighted: false),
        .init(symbol: "pencil.and.list.clipboard", title: "手動で情報を入力して起票", detail: "再現手順や環境情報の記載、ファイルの添付", highlighted: false),
    ]

    private let inAppFlow: [Step] = [
        .init(symbol: "exclamationmark.bubble", title: "バグや改善点を検知", detail: "", highlighted: false),
        .init(symbol: "video", title: "動画の用意", detail: "アプリが自動で記録", highlighted: true),
        .init(symbol: "ladybug", title: "起票", detail: "環境情報などは自動入力", highlighted: true),
        .init(symbol: "gearshape.2", title: "Actionsで下調べ・振り分け", detail: "起票後は自動", highlighted: true),
    ]

    var body: some View {
        HeaderSlide(loc: "バグ起票の流れ: いま と アプリ内バグ起票") {
            // 会場の後ろからも読めるよう、図と文字は本文領域をほぼ使い切る大きさにする(下に少しだけ余白を残す)
            VStack(alignment: .leading, spacing: 44) {
                flowRow(label: "いまの一般的な流れ", steps: currentFlow, visibleCount: currentFlow.count, labelColor: .gray)
                flowRow(
                    label: "アプリ内バグ起票(iPadOSアプリで運用中)",
                    steps: inAppFlow,
                    visibleCount: shows(.second) ? inAppFlow.count : 0,
                    labelColor: .themeColor
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }

    private func flowRow(label: String, steps: [Step], visibleCount: Int, labelColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(label.loc)
                .font(.system(size: 48, weight: .bold))
                .foregroundStyle(labelColor)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .opacity(visibleCount > 0 ? 1 : 0)
            HStack(alignment: .center, spacing: 0) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    let visible = index < visibleCount
                    if index > 0 {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundStyle(.gray)
                            .frame(width: 60)
                            .opacity(visible ? 1 : 0)
                    }
                    VStack(spacing: 14) {
                        Image(systemName: step.symbol)
                            .font(.system(size: 80, weight: .regular))
                            .foregroundStyle(step.highlighted ? Color.themeColor : .defaultForegroundColor)
                            .frame(height: 96)
                        Text(step.title.loc)
                            .font(.system(size: 42, weight: .bold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                        Text(step.detail.isEmpty ? " " : step.detail.loc)
                            .font(.system(size: 34, weight: .regular))
                            .foregroundStyle(step.highlighted ? Color.strokeColor : .gray)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                    }
                    .padding(.vertical, 28)
                    .padding(.horizontal, 10)
                    // 文字の縮小で高さがばらつかないよう、行の中で一番高いカードにそろえる
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color.white.opacity(0.06))
                    )
                    .overlay {
                        if step.highlighted {
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .strokeBorder(Color.themeColor.opacity(0.7), lineWidth: 3)
                        }
                    }
                    .opacity(visible ? 1 : 0)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    SlidePreview {
        IOSFeedbackOverviewSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
