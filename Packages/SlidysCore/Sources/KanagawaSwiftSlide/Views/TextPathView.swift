//
//  TextPathView.swift
//  KanagawaSwiftSlide
//
//  Created by Yugo Sugiyama on 2024/11/02.
//

import SwiftUI
import CoreText
import CoreGraphics

#if os(macOS)
public typealias AppFont = NSFont
#else
public typealias AppFont = UIFont
#endif

struct TextPathView: View {
    let text: String
    let font: AppFont

    var body: some View {
        TextPath(text: text, font: font)
            .stroke(Color.blue, lineWidth: 1)
        //            .frame(width: 300, height: 100)
    }
}

public struct TextPath: Shape {
    public let text: String
    public let font: AppFont

    public init(text: String, font: AppFont) {
        self.text = text
        self.font = font
    }

    public func path(in rect: CGRect) -> Path {
        var combinedPath = Path()

        // Core Textフォントの作成
        let ctFont = CTFontCreateWithName(font.fontName as CFString, font.pointSize, nil)

        // 文字列とフォントの属性付き文字列を作成
        let attributedString = NSAttributedString(string: text, attributes: [.font: ctFont])

        // 属性付き文字列からCTLineを作成
        let line = CTLineCreateWithAttributedString(attributedString)

        // CTLineからグリフランを取得
        let runs = CTLineGetGlyphRuns(line) as! [CTRun]
        for run in runs {
            for i in 0..<CTRunGetGlyphCount(run) {
                var glyph: CGGlyph = 0
                var position = CGPoint()
                CTRunGetGlyphs(run, CFRangeMake(i, 1), &glyph)
                CTRunGetPositions(run, CFRangeMake(i, 1), &position)

                // 各グリフのパスを作成し、結合
                if let letterPath = CTFontCreatePathForGlyph(ctFont, glyph, nil) {
                    let transform = CGAffineTransform(translationX: position.x, y: position.y)
                    combinedPath.addPath(Path(letterPath).applying(transform))
                }
            }
        }

        // テキストの表示領域にスケーリング
        let boundingBox = combinedPath.boundingRect
        let scaleX = rect.width / boundingBox.width
        let scaleY = rect.height / boundingBox.height
        let scale = min(scaleX, scaleY)

        // 上下反転の修正とオフセット調整
        let offsetX = (rect.width - boundingBox.width * scale) / 2 - boundingBox.minX * scale
        let offsetY = (rect.height + boundingBox.height * scale) / 2 + boundingBox.minY * scale
        let transform = CGAffineTransform(translationX: offsetX, y: offsetY).scaledBy(x: scale, y: -scale)

        return combinedPath.applying(transform)
    }
}

#Preview {
    StrokeAnimationShapeView(
        shape: TextPath(
            text: "Hello, SwiftUI!",
            font: AppFont(name: "HeftyRewardSingleLine", size: 40)!
//            font: AppFont.systemFont(ofSize: 40)
        ),
        lineWidth: 2,
        lineColor: .white,
        duration: .seconds(3),
        isPaused: false
    )
//    .frame(width: 200, height: 300)
//    StrokeAnimatableShape(
//        animationProgress: 0.1,
//        shape: TextPath(text: "Hello, SwiftUI!", font: AppFont.systemFont(ofSize: 40))
//    )
    .padding()
}
