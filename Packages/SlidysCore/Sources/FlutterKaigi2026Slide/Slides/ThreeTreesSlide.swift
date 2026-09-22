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
        "ここで少しFlutterの内側の話です。Flutterには3つのツリーがあります。\nまずWidgetツリー。私たちが普段buildで書いている、不変の「設計図」です。画面上の位置は持っていません。",
        "次にElementツリー。Widgetからつくられる「実体」で、ツリーの構造と状態を持っています。WidgetsBinding.instance.rootElementから辿れます。",
        "そしてRenderObjectツリー。レイアウトと描画の実体で、サイズと座標を持っているのはここです。\nつまり「タップして選ぶ」ためにはElementを歩いてRenderObjectに辿り着く必要があります。",
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
        .init(id: 0, name: "Widget", role: "設計図", detail: "build() で書く不変の構成。\n画面上の位置は持たない", hasPosition: false),
        .init(id: 1, name: "Element", role: "実体", detail: "Widget から作られる木。\nrootElement から辿れる", hasPosition: false),
        .init(id: 2, name: "RenderObject", role: "レイアウト・描画", detail: "サイズと座標を持つ。\nlocalToGlobal で画面座標に", hasPosition: true),
    ]

    var body: some View {
        HeaderSlide("Flutterの3つのツリー") {
            HStack(alignment: .top, spacing: 48) {
                ForEach(trees) { tree in
                    let visible = shows(SlidePhase(rawValue: tree.id) ?? .initial)
                    VStack(spacing: 24) {
                        Text(tree.name)
                            .font(.system(size: 60, weight: .heavy))
                            .foregroundStyle(tree.hasPosition ? Color.strokeColor : .themeColor)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                        Text(tree.role)
                            .font(.system(size: 40, weight: .bold))
                        treeGlyph(highlighted: tree.hasPosition)
                            .frame(height: 260)
                        Text(tree.detail)
                            .font(.system(size: 34, weight: .regular))
                            .foregroundStyle(.gray)
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                            .minimumScaleFactor(0.6)
                    }
                    .frame(maxWidth: .infinity)
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
