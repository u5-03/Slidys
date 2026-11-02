//
//  QAFeedbackSlide.swift
//  FlutterKaigi2026Slide
//
//  iPadOS アプリでアプリ内バグ起票を使っている QA チームへのヒアリング結果。
//  上: よかった点 / 下: 大変だった点と、いまの工夫。
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct QAFeedbackSlide: View, PhasedScriptProviding {
    var scriptSegments: [String] {
        [
        "実際に使っている QA チームにヒアリングしてみました。\nよかった点は3つ。1つ目は不具合の場所をエンジニアに明確に伝えられること。2つ目は動画を撮り直さなくていいのが楽な点。3つ目は環境情報などの入力漏れや間違いがなくなったことでした。",
        "一方で大変だったのは、iPad での長文入力です。これはキーボードの音声入力を使ったり、大枠だけ書いて起票し、あとで PC で整えたりする運用でカバーしています。",
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

    private let goodPoints = [
        "不具合の箇所をエンジニアに明確に伝えられる",
        "動画を撮り直さなくていいのが楽",
        "環境情報などの入力漏れ・間違いがなくなった",
    ]

    var body: some View {
        HeaderSlide(loc: "QA チームに聞いてみた") {
            VStack(alignment: .leading, spacing: 32) {
                card(title: "よかった点".loc, systemImage: "hand.thumbsup.fill", color: .themeColor) {
                    VStack(alignment: .leading, spacing: 14) {
                        ForEach(goodPoints, id: \.self) { point in
                            bullet(point.loc)
                        }
                    }
                }
                card(title: "大変だった点と工夫".loc, systemImage: "wrench.and.screwdriver.fill", color: .strokeColor) {
                    VStack(alignment: .leading, spacing: 20) {
                        bullet("iPad での長文入力は大変".loc)
                        HStack(alignment: .firstTextBaseline, spacing: 12) {
                            Image(systemName: "arrow.turn.down.right")
                                .foregroundStyle(Color.strokeColor)
                            Text("音声入力で書く・大枠だけ起票して PC で整える".loc)
                                .foregroundStyle(Color.strokeColor)
                        }
                        .font(.system(size: 38, weight: .semibold))
                        .padding(.leading, 20)
                    }
                }
                .opacity(shows(.second) ? 1 : 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }

    private func bullet(_ text: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text("・")
            Text(text)
                .fixedSize(horizontal: false, vertical: true)
        }
        .font(.system(size: 44, weight: .semibold))
    }

    private func card<Content: View>(
        title: String,
        systemImage: String,
        color: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Label(title, systemImage: systemImage)
                .font(.system(size: 48, weight: .heavy))
                .foregroundStyle(color)
            content()
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 28)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
    }
}

#Preview {
    SlidePreview {
        QAFeedbackSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
