//
//  ReplayDesignBranchSlide.swift
//  FlutterKaigi2026Slide
//
//  ③動画エンコードをどう解くかの設計分岐(A: 薄いMethodChannel / B: 純DartでAPNG / C: パッケージ)。
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct ReplayDesignBranchSlide: View, PhasedScriptProviding {
    /// スピーカーノート(フェーズごとのセグメント。区切りがスライド内の「次を表示」位置)
    var scriptSegments: [String] {
        [
        "③をどう解くか、選択肢は3つです。\nA、薄い MethodChannel でネイティブのエンコーダを叩く。iOS なら AVAssetWriter、Android なら MediaCodec。数十行のチャネルで mp4 が出せます。",
        "B、純 Dart で APNG や GIF を自作する。ネイティブもパッケージも無しの唯一解ですが、ファイルサイズが大きい。",
        "C、ffmpeg_kit などのパッケージ。重いのとメンテ状況に注意が必要です。",
        "今回は A を選びました。「静止画は Flutter、動画化はデバイス」という役割分担です。iOS 版の AVAssetWriter のコードがほぼそのまま流用できたのも大きいです。",
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

    private struct Option: Identifiable {
        let id: Int
        let label: String
        let title: String
        let native: String
        let package: String
        let output: String
        let note: String
    }

    private let options: [Option] = [
        .init(id: 0, label: "A", title: "薄い MethodChannel でネイティブのエンコーダ", native: "要(薄い)", package: "不要", output: "mp4",
              note: "iOS: AVAssetWriter / Android: MediaCodec"),
        .init(id: 1, label: "B", title: "純 Dart で APNG / GIF を自作", native: "不要", package: "不要", output: "apng / gif",
              note: "PNG を束ねるだけ。ただしサイズが大きい"),
        .init(id: 2, label: "C", title: "ffmpeg_kit などのパッケージ", native: "不要", package: "要", output: "mp4",
              note: "重い・メンテ状況に注意"),
    ]

    var body: some View {
        HeaderSlide("③ 動画エンコードをどう解くか") {
            VStack(spacing: 24) {
                // 見出し行
                HStack(spacing: 24) {
                    Text("")
                        .frame(width: 90)
                    Text("方式")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Native")
                        .frame(width: 200)
                    Text("Package")
                        .frame(width: 200)
                    Text("出力")
                        .frame(width: 220)
                }
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(.gray)
                .padding(.horizontal, 32)

                ForEach(options) { option in
                    let visible = shows(SlidePhase(rawValue: option.id) ?? .initial)
                    let chosen = option.id == 0 && shows(.fourth)
                    HStack(spacing: 24) {
                        Text(option.label)
                            .font(.system(size: 64, weight: .heavy))
                            .foregroundStyle(chosen ? Color.strokeColor : .themeColor)
                            .frame(width: 90)
                        VStack(alignment: .leading, spacing: 8) {
                            Text(option.title)
                                .font(.system(size: 40, weight: .bold))
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                            Text(option.note)
                                .font(.system(size: 30, weight: .regular))
                                .foregroundStyle(.gray)
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        Text(option.native)
                            .frame(width: 200)
                        Text(option.package)
                            .frame(width: 200)
                        Text(option.output)
                            .frame(width: 220)
                    }
                    .font(.system(size: 36, weight: .semibold))
                    .padding(.horizontal, 32)
                    .padding(.vertical, 24)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color.white.opacity(chosen ? 0.12 : 0.06))
                    )
                    .overlay {
                        if chosen {
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .strokeBorder(Color.strokeColor, lineWidth: 4)
                        }
                    }
                    .opacity(visible ? 1 : 0)
                }

                if shows(.fourth) {
                    Text("今回は A: 静止画は Flutter、動画化はデバイスに任せる")
                        .font(.system(size: 44, weight: .heavy))
                        .foregroundStyle(Color.strokeColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .padding(.top, 12)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}

#Preview {
    SlidePreview {
        ReplayDesignBranchSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
