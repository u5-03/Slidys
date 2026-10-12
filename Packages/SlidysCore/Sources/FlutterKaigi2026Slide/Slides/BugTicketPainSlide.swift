//
//  BugTicketPainSlide.swift
//  FlutterKaigi2026Slide
//
//  つかみ: 情報の足りないバグチケットで困ること。
//  中央に修正する人を置き、その周りに「足りないもの」を吹き出しで 1 つずつ出す。
//  最後のページ送りで、起票する側も大変だという一文をアクセントカラーで下に出す。
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct BugTicketPainSlide: View, PhasedScriptProviding {
    /// スピーカーノート(吹き出し 4 つ → 最後の一文、の順に 1 つずつ)
    var scriptSegments: [String] {
        [
        "例えば、再現手順がはっきり書かれていない。",
        "OS やデバイスの種類、ビルド番号といった環境情報がない。",
        "画像や動画の添付がない。",
        "画面のどこで起きたのかがわからない。そんな状態でバグ修正のときに困った方もいるのではないでしょうか？",
        "もちろん、バグチケットを起票する側も、それを全部書くのは大変です。",
        ]
    }

    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }
    @Environment(\.revealsAllPhases) private var revealsAllPhases
    @Environment(\.previewPhaseStep) private var previewPhaseStep
    @Phase private var phase: SlidePhase

    enum SlidePhase: Int, PhasedState {
        case initial, second, third, fourth, fifth
    }

    private func shows(_ step: SlidePhase) -> Bool {
        if revealsAllPhases { return true }
        if let previewPhaseStep { return previewPhaseStep >= step.rawValue }
        return phase.isAfter(step)
    }

    private struct Bubble: Identifiable {
        let id: Int
        let text: String
        let detail: String
        /// 吹き出しの中心(スライド原寸 1920x1080 の座標)
        let center: CGPoint
        /// しっぽを出す角(人のいる中央側)
        let tail: SpeechBubbleShape.Tail
    }

    private let bubbles: [Bubble] = [
        .init(id: 0, text: "再現手順が不明確", detail: "", center: CGPoint(x: 440, y: 235), tail: .bottomTrailing),
        .init(id: 1, text: "環境情報がない", detail: "OS・デバイス・ビルド番号", center: CGPoint(x: 1480, y: 235), tail: .bottomLeading),
        .init(id: 2, text: "画像や動画がない", detail: "", center: CGPoint(x: 440, y: 690), tail: .topTrailing),
        .init(id: 3, text: "画面のどこかわからない", detail: "", center: CGPoint(x: 1480, y: 690), tail: .topLeading),
    ]

    private let bubbleSize = CGSize(width: 640, height: 170)

    var body: some View {
        ZStack {
            person
                .position(x: 960, y: 470)
            ForEach(bubbles) { bubble in
                let visible = shows(SlidePhase(rawValue: bubble.id) ?? .initial)
                bubbleView(bubble)
                    .position(bubble.center)
                    .opacity(visible ? 1 : 0)
                    .scaleEffect(visible ? 1 : 0.85)
                    .animation(.spring(duration: 0.3), value: visible)
            }
            // 最後のページ送りで出す一文(アクセントカラー)
            Text("もちろん、バグチケットの起票も大変です".loc)
                .font(.system(size: 66, weight: .heavy))
                .foregroundStyle(Color.strokeColor)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .frame(width: 1700)
                .position(x: 960, y: 940)
                .opacity(shows(.fifth) ? 1 : 0)
                .animation(.easeOut(duration: 0.3), value: shows(.fifth))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.slideBackgroundColor)
        .foregroundColor(.defaultForegroundColor)
    }

    /// 中央の「修正する人」
    private var person: some View {
        VStack(spacing: 14) {
            Image(systemName: "person.fill.questionmark")
                .font(.system(size: 150, weight: .regular))
                .frame(width: 290, height: 290)
                .background(Circle().fill(Color.white.opacity(0.08)))
            Text("エンジニア".loc)
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(.gray)
        }
    }

    private func bubbleView(_ bubble: Bubble) -> some View {
        VStack(spacing: 6) {
            Text(bubble.text.loc)
                .font(.system(size: 52, weight: .heavy))
            if !bubble.detail.isEmpty {
                Text(bubble.detail.loc)
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(.gray)
            }
        }
        .lineLimit(1)
        .minimumScaleFactor(0.6)
        .padding(.horizontal, 36)
        .frame(width: bubbleSize.width, height: bubbleSize.height)
        .background(
            SpeechBubbleShape(tail: bubble.tail)
                .fill(Color.white.opacity(0.12))
        )
    }
}

/// 角丸の四角に、上辺か下辺から斜めのしっぽを付けた吹き出し
private struct SpeechBubbleShape: Shape {
    enum Tail {
        case topLeading, topTrailing, bottomLeading, bottomTrailing
    }

    let tail: Tail

    func path(in rect: CGRect) -> Path {
        var path = Path(roundedRect: rect, cornerRadius: 40, style: .continuous)
        let isTop = tail == .topLeading || tail == .topTrailing
        let isLeading = tail == .topLeading || tail == .bottomLeading
        // しっぽの付け根は辺の内側に少し食い込ませて、継ぎ目が出ないようにする
        let edgeY = isTop ? rect.minY + 2 : rect.maxY - 2
        let tipY = isTop ? rect.minY - 64 : rect.maxY + 64
        let edgeX = isLeading ? rect.minX : rect.maxX
        let direction: CGFloat = isLeading ? 1 : -1
        path.move(to: CGPoint(x: edgeX + direction * 90, y: edgeY))
        path.addLine(to: CGPoint(x: edgeX + direction * 180, y: edgeY))
        path.addLine(to: CGPoint(x: edgeX + direction * 30, y: tipY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    SlidePreview {
        BugTicketPainSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
