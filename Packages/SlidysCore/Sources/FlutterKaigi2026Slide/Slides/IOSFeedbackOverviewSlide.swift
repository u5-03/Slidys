//
//  IOSFeedbackOverviewSlide.swift
//  FlutterKaigi2026Slide
//
//  iOS アプリで運用している「アプリ内バグ起票」の全体像を、
//  アプリ → 自動収集 → Issue → GitHub Actions の流れで見せる。
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct IOSFeedbackOverviewSlide: View, PhasedScriptProviding {
    /// スピーカーノート(フェーズごとのセグメント。区切りがスライド内の「次を表示」位置)
    var scriptSegments: [String] {
        [
        "まず前提として、iOSアプリでは社内向けにこういう仕組みを運用しています。\nデバッグビルドにフローティングボタンがあって、そこから起票画面を開きます。",
        "起票の瞬間に、スクリーンショット、直前60秒の動画、View階層、ログ、環境情報などを自動で集めます。",
        "それらをストレージに上げて、GitHub Issueをその場で起票します。人が書くのはタイトルと一言だけです。",
        "起票後はGitHub Actionsがラベルを見て、Projectへの振り分けやAIの下調べまで自動でやってくれます。\nこれをFlutterでも作れるのか？が今日の話です。",
        ]
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

    private func shows(_ step: SlidePhase) -> Bool {
        if revealsAllPhases { return true }
        if let previewPhaseStep { return previewPhaseStep >= step.rawValue }
        return phase.isAfter(step)
    }

    private struct Step: Identifiable {
        let id: Int
        let symbol: String
        let title: String
        let detail: String
    }

    private let steps: [Step] = [
        .init(id: 0, symbol: "iphone", title: "アプリ内の起票画面", detail: "フローティングボタンから開く"),
        .init(id: 1, symbol: "square.and.arrow.down.on.square", title: "自動収集", detail: "スクショ・動画・階層・ログ・環境"),
        .init(id: 2, symbol: "ladybug", title: "GitHub Issue", detail: "その場で起票"),
        .init(id: 3, symbol: "gearshape.2", title: "GitHub Actions", detail: "振り分け・AI下調べ"),
    ]

    var body: some View {
        HeaderSlide("iOSアプリで運用している「アプリ内バグ起票」") {
            // カードの高さを揃え、矢印はその縦中央に置く
            HStack(alignment: .center, spacing: 0) {
                ForEach(steps) { step in
                    let visible = shows(SlidePhase(rawValue: step.id) ?? .initial)
                    if step.id > 0 {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 56, weight: .bold))
                            .foregroundStyle(.gray)
                            .frame(maxHeight: .infinity)
                            .opacity(visible ? 1 : 0)
                    }
                    VStack(spacing: 28) {
                        Image(systemName: step.symbol)
                            .font(.system(size: 120, weight: .regular))
                            .foregroundStyle(.themeColor)
                            .frame(height: 150)
                        Text(step.title)
                            .font(.system(size: 44, weight: .bold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                        Text(step.detail)
                            .font(.system(size: 32, weight: .regular))
                            .foregroundStyle(.gray)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.6)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.vertical, 40)
                    .background(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(Color.white.opacity(0.06))
                    )
                    .opacity(visible ? 1 : 0)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 560)
            .frame(maxHeight: .infinity, alignment: .center)
        }
    }
}

#Preview {
    SlidePreview {
        IOSFeedbackOverviewSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
