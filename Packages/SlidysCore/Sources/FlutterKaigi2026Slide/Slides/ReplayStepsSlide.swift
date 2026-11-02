//
//  ReplayStepsSlide.swift
//  FlutterKaigi2026Slide
//
//  画面リプレイを「① フレーム取得 / ② リングバッファ / ③ 動画エンコード」の3段階に分け、
//  Flutter だけで実現できるか(◎ / ×)を段階的に見せる。③が × になるのがこの章の山場。
//  右には実機のリプレイ画面(静止画を撮り続けて mp4 にする)を埋め込む。
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct ReplayStepsSlide: View, PhasedScriptProviding {
    /// スピーカーノート(フェーズごとのセグメント。区切りがスライド内の「次を表示」位置)
    var scriptSegments: [String] {
        [
        "動画の保存は3つのステップになっています。最初はフレーム取得。Flutter だけでも toImage で撮れますが、Flutter が描いた部分しか写らず、地図や WebView などの PlatformView が黒くなります。それでは実用にならないので、撮影はネイティブのView ごと撮ります。",
        "2つ目のリングバッファは Flutter だけでできます。PNG を書き続けて、古いものを消すだけです。",
        "問題は3つめの動画エンコードです。標準のDart自体には動画エンコーダがないので、ここもネイティブのエンコーダを MethodChannel で呼びます。撮影と動画化はネイティブ、溜めて管理するのは Flutter、という分担です。",
        ]
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

    private func shows(_ step: SlidePhase) -> Bool {
        if revealsAllPhases { return true }
        if let previewPhaseStep { return previewPhaseStep >= step.rawValue }
        return phase.isAfter(step)
    }

    private struct Step: Identifiable {
        let id: Int
        let title: String
        let verdict: String
        let ok: Bool
        let detail: String
    }

    private let steps: [Step] = [
        .init(id: 0, title: "① フレーム取得", verdict: "△ Flutterだけだと不十分", ok: false,
              detail: "toImage では PlatformView が黒い → ネイティブで View 階層ごと撮る"),
        .init(id: 1, title: "② リングバッファ", verdict: "◎ Flutterだけで可", ok: true,
              detail: "tmp に PNG を書き続けて、古い分を削除"),
        .init(id: 2, title: "③ 動画エンコード", verdict: "× 標準のDart自体にはエンコーダがない", ok: false,
              detail: "ネイティブのエンコーダを MethodChannel で呼ぶ"),
    ]

    var body: some View {
        HeaderSlide(loc: "3段階に分けて考える") {
            VStack(spacing: 32) {
                ForEach(steps) { step in
                    let visible = shows(SlidePhase(rawValue: step.id) ?? .initial)
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .firstTextBaseline, spacing: 32) {
                            Text(step.title.loc)
                                .font(.system(size: 52, weight: .heavy))
                                .frame(width: 430, alignment: .leading)
                            Text(step.verdict.loc)
                                .font(.system(size: 44, weight: .bold))
                                .foregroundStyle(step.ok ? Color.themeColor : Color.strokeColor)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        Text(step.detail.loc)
                            .font(.system(size: 32, weight: .regular))
                            .foregroundStyle(.gray)
                    }
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .padding(.horizontal, 36)
                    .padding(.vertical, 28)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(Color.white.opacity(0.06))
                    )
                    .overlay {
                        if !step.ok {
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .strokeBorder(Color.strokeColor, lineWidth: 4)
                        }
                    }
                    .opacity(visible ? 1 : 0)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}

#Preview {
    SlidePreview {
        ReplayStepsSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
