//
//  QuizAnimationSlide.swift
//  KanagawaSwiftSlide
//
//  Created by Yugo Sugiyama on 2024/09/08.
//

import SwiftUI
import SlideKit
import SymbolKit
import SlidesCore

@Slide
struct QuizAnimationSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    let title: String
    let answer: String
    let answerHint: String?
    let shape: any Shape
    let shapeAspectRatio: CGFloat
    @State private var isPaused = true
    @State private var shouldShowCorrectMark = false
    @State private var shouldShowNotCorrectMark = false
    @State private var shouldShowAnswer = false
    @State private var shouldShowAnswerName = false
    @FocusState private var isFocused: Bool
    let answerDuration: CGFloat = 5

    init(title: String, answer: String, answerHint: String? = nil, shape: any Shape, shapeAspectRatio: CGFloat = 1) {
        self.title = title
        self.answer = answer
        self.answerHint = answerHint
        self.shape = shape
        self.shapeAspectRatio = shapeAspectRatio
    }

    var body: some View {
        SymbolQuizView(
            titleContent: {
                Text(title)
                    .font(.largeFont)
                    .foregroundStyle(.themeColor)
            }, answerPrefixContent: {
                Text("正解:")
                    .font(.midiumFont)
                    .foregroundStyle(.defaultForegroundColor)
            }, answerContent: {
                Text(answer)
                    .font(.largeFont)
                    .foregroundStyle(.strokeColor)
            }, showAnswerContent: {
                Text("正解を表示")
                    .font(.midiumFont)
                    .foregroundStyle(.defaultForegroundColor)
            }, answerHintContent: {
                Text(answerHint ?? "")
                    .font(.midiumFont)
                    .foregroundStyle(.defaultForegroundColor)
            },
            shape: shape,
            shapeAspectRatio: shapeAspectRatio
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.slideBackgroundColor)
    }
}

#Preview {
    SlidePreview {
        QuizAnimationSlide(
            title: "千葉シンボルクイズ 第1問",
            answer: "ピーナッツ",
            answerHint: "ヒント",
            shape: UhooiShape(),
            shapeAspectRatio: 990 / 617
        )
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
