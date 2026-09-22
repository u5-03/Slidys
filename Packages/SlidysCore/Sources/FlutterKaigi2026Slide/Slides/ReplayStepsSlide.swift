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
        "右のアプリは起動時から裏で静止画を撮り続けていて、「動画にする」を押すと直近の分を mp4 にして共有できます。\nまず①フレーム取得。これは Flutter だけでできます。アプリ全体を RepaintBoundary で包んで、toImageSync でシーンをスナップショットします。toImage と違って同期で GPU 側の処理なので、連射に耐えます。",
        "②リングバッファもできます。tmp に PNG を書き続けて、古いものを消すだけ。全部メモリに持つと OOM になるので、ファイル方式が正解です。",
        "問題は③動画エンコード。Dart SDK には動画エンコーダがありません。dart:ui の出力は静止画の PNG まで。ここが唯一で、本質的な設計の分岐点です。",
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
        .init(id: 0, title: "① フレーム取得", verdict: "◎ Flutterだけで可", ok: true,
              detail: "RepaintBoundary + toImageSync()"),
        .init(id: 1, title: "② リングバッファ", verdict: "◎ Flutterだけで可", ok: true,
              detail: "tmp に PNG を書き続けて、古い分を削除"),
        .init(id: 2, title: "③ 動画エンコード", verdict: "× Dartだけでは不可", ok: false,
              detail: "Dart SDK に動画エンコーダがない"),
    ]

    var body: some View {
        HeaderSlide("3段階に分けて考える") {
            HStack(alignment: .top, spacing: 60) {
                VStack(spacing: 32) {
                    ForEach(steps) { step in
                        let visible = shows(SlidePhase(rawValue: step.id) ?? .initial)
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(alignment: .firstTextBaseline, spacing: 32) {
                                Text(step.title)
                                    .font(.system(size: 52, weight: .heavy))
                                    .frame(width: 430, alignment: .leading)
                                Text(step.verdict)
                                    .font(.system(size: 44, weight: .bold))
                                    .foregroundStyle(step.ok ? Color.themeColor : Color.strokeColor)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            Text(step.detail)
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
                .frame(maxWidth: .infinity, alignment: .top)

                PhoneFrameView {
                    FlutterView(type: .screenReplay)
                }
                .frame(maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
