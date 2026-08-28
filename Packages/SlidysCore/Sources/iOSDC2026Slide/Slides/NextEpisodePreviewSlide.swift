//
//  NextEpisodePreviewSlide.swift
//  iOSDC2026Slide
//
//  アニメの次回予告カード風スライド。
//  青系の光る背景 + 白文字に黒フチ(丸ゴシック)で、あの「次回予告」の画面に寄せる。
//  作品名は出さない(文字も一部伏せ字)。
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct NextEpisodePreviewSlide: View {
    let mainText: String
    let mainFontSize: CGFloat

    init(mainText: String, mainFontSize: CGFloat = 170) {
        self.mainText = mainText
        self.mainFontSize = mainFontSize
    }

    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        ZStack {
            background

            VStack(alignment: .leading, spacing: 90) {
                OutlinedText(text: "次回予告", fontSize: 90)
                    .padding(.leading, 60)

                OutlinedText(text: mainText, fontSize: mainFontSize)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 80)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding(.top, -60)
        }
    }

    // MARK: - 背景(青の光 + キラキラ)

    private var background: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.13, green: 0.25, blue: 0.55),
                    Color(red: 0.35, green: 0.55, blue: 0.85),
                    Color(red: 0.18, green: 0.32, blue: 0.62),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // 上から降り注ぐ光の筋
            ForEach(Array(Self.lightStreaks.enumerated()), id: \.offset) { _, streak in
                LinearGradient(
                    colors: [.white.opacity(0), .white.opacity(streak.opacity), .white.opacity(0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(width: streak.width, height: 1400)
                .rotationEffect(.degrees(streak.angle))
                .position(x: streak.x, y: streak.y)
                .blendMode(.screen)
            }

            // 4方向に伸びるキラキラ
            ForEach(Array(Self.sparkles.enumerated()), id: \.offset) { _, sparkle in
                SparkleShape()
                    .fill(Color.white.opacity(sparkle.opacity))
                    .frame(width: sparkle.size, height: sparkle.size)
                    .position(x: sparkle.x, y: sparkle.y)
                    .blendMode(.screen)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
    }

    // 座標は1920×1080基準(SlideKitの論理サイズ)。毎回同じ見た目になるよう固定値
    private static let sparkles: [(x: CGFloat, y: CGFloat, size: CGFloat, opacity: CGFloat)] = [
        (180, 160, 90, 0.9), (420, 520, 50, 0.6), (300, 860, 70, 0.7),
        (700, 220, 44, 0.5), (960, 700, 100, 0.8), (1150, 180, 60, 0.7),
        (1420, 420, 80, 0.85), (1660, 260, 48, 0.55), (1740, 760, 92, 0.8),
        (1280, 940, 56, 0.6), (620, 960, 40, 0.5), (860, 90, 52, 0.6),
    ]

    private static let lightStreaks: [(x: CGFloat, y: CGFloat, width: CGFloat, angle: Double, opacity: CGFloat)] = [
        (260, 540, 90, 14, 0.16), (640, 500, 140, 10, 0.12),
        (1060, 560, 110, 16, 0.14), (1480, 520, 160, 12, 0.10),
        (1760, 560, 80, 18, 0.14),
    ]
}

/// アニメの字幕・タイトル風の「白文字+黒フチ」テキスト。
/// 黒フチは8方向にずらした黒文字を背面に重ねて表現する。
private struct OutlinedText: View {
    let text: String
    let fontSize: CGFloat

    private var font: Font {
        // 丸ゴシック(HiraMaruProN)でアニメのテロップ感に寄せる。無ければ丸めの角ゴシックにフォールバック
        .custom("Hiragino Maru Gothic ProN", size: fontSize)
    }

    private var outlineWidth: CGFloat { max(3, fontSize * 0.045) }

    var body: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { index in
                let angle = CGFloat(index) * .pi / 4
                textBody
                    .foregroundStyle(.black)
                    .offset(x: cos(angle) * outlineWidth, y: sin(angle) * outlineWidth)
            }
            textBody
                .foregroundStyle(.white)
        }
        .shadow(color: .black.opacity(0.5), radius: 6, x: 4, y: 6)
    }

    private var textBody: some View {
        Text(text)
            .font(font)
            .bold()
            .multilineTextAlignment(.center)
            .lineSpacing(20)
            .minimumScaleFactor(0.5)
    }
}

/// 4方向に伸びる十字のキラキラ(光芒)
private struct SparkleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let long = rect.width / 2
        let thin = rect.width * 0.07

        // 縦横の細長いひし形を重ねる
        path.move(to: CGPoint(x: center.x, y: center.y - long))
        path.addQuadCurve(to: CGPoint(x: center.x + long, y: center.y), control: CGPoint(x: center.x + thin, y: center.y - thin))
        path.addQuadCurve(to: CGPoint(x: center.x, y: center.y + long), control: CGPoint(x: center.x + thin, y: center.y + thin))
        path.addQuadCurve(to: CGPoint(x: center.x - long, y: center.y), control: CGPoint(x: center.x - thin, y: center.y + thin))
        path.addQuadCurve(to: CGPoint(x: center.x, y: center.y - long), control: CGPoint(x: center.x - thin, y: center.y - thin))
        path.closeSubpath()
        return path
    }
}

#Preview("城⚫︎内⚫︎す") {
    SlidePreview {
        NextEpisodePreviewSlide(mainText: "城⚫︎内⚫︎す")
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}

#Preview("いつかやってみたかった") {
    SlidePreview {
        NextEpisodePreviewSlide(
            mainText: "みんなが「いつかやってみたかった」を\n実現する",
            mainFontSize: 110
        )
    }
    .headerSlideStyle(CustomHeaderSlideStyle(listTextStyle: .large))
    .itemStyle(CustomItemStyle())
}
