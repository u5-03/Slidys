//
//  DiagnosticsTableSlide.swift
//  FlutterKaigi2026Slide
//
//  Issue に自動で載せる診断情報の「種類 / 役割 / Flutter での取り方」を一覧にする。
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct DiagnosticsTableSlide: View, PhasedScriptProviding {
    /// スピーカーノート(フェーズごとのセグメント。区切りがスライド内の「次を表示」位置)
    var scriptSegments: [String] {
        [
        "3つ目、実行時の情報の添付です。Issue に自動で載せているのはこの6種類です。\n選択した UI 要素は、さっきの identifier。「どの画面のどの部品か」の曖昧さを消して、コードへの最短のアンカーになります。",
        "Widget 階層は、その瞬間の画面構造のスナップショット。要素ピッカーと同じ走査でテキスト化します。",
        "ログは「再現しません」を減らす最大の武器。ただし Flutter には iOS の OSLogStore 相当がないので、自前で溜める必要があります。ここが移植の最大の差分です。",
        "スタックトレースは StackTrace.current をそのまま。環境情報は PlatformDispatcher や package_info から。スクリーンショットはリプレイと同じ RepaintBoundary から取ります。",
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

    private struct Row: Identifiable {
        let id: Int
        let phase: SlidePhase
        let kind: String
        let role: String
        let how: String
    }

    private let rows: [Row] = [
        .init(id: 0, phase: .initial, kind: "選択したUI要素", role: "報告とコードを結ぶアンカー", how: "ElementPicker の identifier"),
        .init(id: 1, phase: .second, kind: "Widget階層", role: "その瞬間の画面構造", how: "rootElement を再帰してテキスト化"),
        .init(id: 2, phase: .third, kind: "ログ", role: "直前に何が起きていたか", how: "自前のリングバッファ(OSLogStore相当が無い)"),
        .init(id: 3, phase: .fourth, kind: "スタックトレース", role: "どの経路で来たか", how: "StackTrace.current"),
        .init(id: 4, phase: .fourth, kind: "環境情報", role: "端末・OS・バージョン依存の切り分け", how: "PlatformDispatcher / package_info"),
        .init(id: 5, phase: .fourth, kind: "スクリーンショット", role: "見た目の証拠", how: "RepaintBoundary.toImage()"),
    ]

    var body: some View {
        HeaderSlide("Issueに自動で載せる情報") {
            VStack(spacing: 0) {
                HStack(spacing: 24) {
                    Text("種類").frame(width: 360, alignment: .leading)
                    Text("役割").frame(maxWidth: .infinity, alignment: .leading)
                    Text("Flutterでの取り方").frame(width: 720, alignment: .leading)
                }
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(.gray)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                Rectangle()
                    .fill(Color.defaultForegroundColor.opacity(0.5))
                    .frame(height: 3)
                ForEach(rows) { row in
                    let visible = shows(row.phase)
                    HStack(spacing: 24) {
                        Text(row.kind)
                            .font(.system(size: 40, weight: .bold))
                            .foregroundStyle(.themeColor)
                            .frame(width: 360, alignment: .leading)
                        Text(row.role)
                            .font(.system(size: 34, weight: .semibold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(row.how)
                            .font(.system(size: 32, weight: .regular, design: .monospaced))
                            .foregroundStyle(.gray)
                            .frame(width: 720, alignment: .leading)
                    }
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                    .opacity(visible ? 1 : 0)
                    Rectangle()
                        .fill(Color.defaultForegroundColor.opacity(0.2))
                        .frame(height: 2)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}

#Preview {
    SlidePreview {
        DiagnosticsTableSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
