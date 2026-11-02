//
//  ThreeTreesSlide.swift
//  FlutterKaigi2026Slide
//
//  Widget / Element / RenderObject の3つのツリーを横に並べ、
//  「画面上の位置を持っているのはどれか」を段階的に見せる。
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct ThreeTreesSlide: View, PhasedScriptProviding {
    /// スピーカーノート(フェーズごとのセグメント。区切りがスライド内の「次を表示」位置)
    var scriptSegments: [String] {
        [
        "では次に少し仕組みの話をします。Flutter は画面を3つのツリーで管理しています。\nWidget は build で書く「設計図」。描き直されるもので、位置は持っていません。",
        "Element は、設計図から建てた「部品の台帳」。設計図と実物の両方を知っています。",
        "RenderObject は「実物」で、サイズと座標を持つのはここだけです。\nなので、Element をたどって、そこから RenderObject の位置を取ります。",
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

    private struct Tree: Identifiable {
        let id: Int
        let name: String
        let role: String
        let detail: String
        let hasPosition: Bool
    }

    private let trees: [Tree] = [
        .init(id: 0, name: "Widget", role: "設計図", detail: "build() で書く不変の構成。\n状態が変わるたび描き直される。\n位置もサイズも持たない", hasPosition: false),
        .init(id: 1, name: "Element", role: "部品の台帳", detail: "設計図から建てられた実体の一覧。\n設計図と実物の両方を知っている。\nrootElement が根", hasPosition: false),
        .init(id: 2, name: "RenderObject", role: "実物(レイアウト・描画)", detail: "サイズと座標を持つのはここだけ。\nlocalToGlobal で画面座標に", hasPosition: true),
    ]

    var body: some View {
        HeaderSlide(loc: "Flutterの3つのツリー") {
            HStack(alignment: .top, spacing: 48) {
                ForEach(trees) { tree in
                    let visible = shows(SlidePhase(rawValue: tree.id) ?? .initial)
                    VStack(spacing: 24) {
                        Text(tree.name)
                            .font(.system(size: 60, weight: .heavy))
                            .foregroundStyle(tree.hasPosition ? Color.strokeColor : .themeColor)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                        Text(tree.role.loc)
                            .font(.system(size: 40, weight: .bold))
                        treeGlyph(highlighted: tree.hasPosition)
                            .frame(height: 260)
                        Text(tree.detail.loc)
                            .font(.system(size: 34, weight: .regular))
                            .foregroundStyle(.gray)
                            .multilineTextAlignment(.center)
                            .lineLimit(4)
                            .minimumScaleFactor(0.6)
                        Spacer(minLength: 0)
                    }
                    // 3枚とも同じ高さにそろえる(HStack 側の fixedSize で一番高いカードに合わせる)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.vertical, 36)
                    .padding(.horizontal, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(Color.white.opacity(0.06))
                    )
                    .overlay {
                        if tree.hasPosition {
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .strokeBorder(Color.strokeColor, lineWidth: 4)
                        }
                    }
                    .opacity(visible ? 1 : 0)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }

    /// 簡易なツリー図。RenderObject だけノードに座標っぽい枠を付ける
    private func treeGlyph(highlighted: Bool) -> some View {
        let node = Circle()
            .fill(highlighted ? Color.strokeColor : Color.defaultForegroundColor)
        return VStack(spacing: 28) {
            node.frame(width: 44, height: 44)
            HStack(spacing: 80) {
                node.frame(width: 44, height: 44)
                node.frame(width: 44, height: 44)
            }
            HStack(spacing: 36) {
                node.frame(width: 44, height: 44)
                node.frame(width: 44, height: 44)
                node.frame(width: 44, height: 44)
                node.frame(width: 44, height: 44)
            }
        }
        .overlay {
            if highlighted {
                // 座標を持つことの比喩として、破線の矩形を重ねる
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(style: StrokeStyle(lineWidth: 4, dash: [16, 12]))
                    .foregroundStyle(Color.strokeColor)
                    .padding(-24)
            }
        }
    }
}

#Preview {
    SlidePreview {
        ThreeTreesSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
