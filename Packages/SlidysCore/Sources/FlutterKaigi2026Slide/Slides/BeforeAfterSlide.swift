//
//  BeforeAfterSlide.swift
//  FlutterKaigi2026Slide
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct BeforeAfterSlide: View, PhasedScriptProviding {
    /// スピーカーノート(フェーズごとのセグメント。区切りがスライド内の「次を表示」位置)
    var scriptSegments: [String] {
        [
        "効果をまとめると、Before はこうでした。報告は「どこかの画面でなんか変」、開発者は「どの画面？」「再現しない」から始まる。",
        "After は、報告する人は「タップして一言」だけ。開発者には最初から直せる情報が揃っています。報告する人の手間を減らしつつ、直す人の最初の一歩を短くする。両方がラクになります。",
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

    var body: some View {
        HeaderSlide("報告する人も、直す人もラクになる") {
            HStack(alignment: .top, spacing: 48) {
                column(
                    title: "Before",
                    color: .gray,
                    reporter: "「どこかの画面でなんか変」\n再現手順を思い出しながら文章で書く",
                    developer: "「どの画面？」「再現しない」\n環境を聞き返すところから始まる"
                )
                Image(systemName: "arrow.right")
                    .font(.system(size: 72, weight: .bold))
                    .foregroundStyle(.gray)
                    .frame(maxHeight: .infinity)
                    .opacity(shows(.second) ? 1 : 0)
                column(
                    title: "After",
                    color: .themeColor,
                    reporter: "タップ + 一言\n収集は機械にまかせる",
                    developer: "最初から直せる情報が揃う\nどのWidget・直前60秒の動画・ログ・環境"
                )
                .opacity(shows(.second) ? 1 : 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func column(title: String, color: Color, reporter: String, developer: String) -> some View {
        VStack(alignment: .leading, spacing: 32) {
            Text(title)
                .font(.system(size: 64, weight: .heavy))
                .foregroundStyle(color)
            cell(label: "報告する人", text: reporter)
            cell(label: "直す人", text: developer)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(36)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(color.opacity(0.6), lineWidth: 4)
        }
    }

    private func cell(label: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(label)
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(.gray)
            Text(text)
                .font(.system(size: 38, weight: .semibold))
                .lineSpacing(8)
                .lineLimit(3)
                .minimumScaleFactor(0.6)
        }
    }
}

#Preview {
    SlidePreview {
        BeforeAfterSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
