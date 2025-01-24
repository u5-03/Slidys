//
//  QuizAnimationSlide.swift
//  KanagawaSwiftSlide
//
//  Created by Yugo Sugiyama on 2024/09/08.
//

import SwiftUI
import SlideKit
import SymbolKit

@Slide
public struct QuizAnimationSlide: View {
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
    let questionDrawingDuration: Duration
    let answerDrawingDuration: Duration
    let pathAnimationType: PathAnimationType

    public init(
        title: String,
        answer: String,
        answerHint: String? = nil,
        shape: any Shape,
        shapeAspectRatio: CGFloat = 1,
        pathAnimationType: PathAnimationType = .progressiveDraw,
        questionDrawingDuration: Duration = .seconds(60),
        answerDrawingDuration: Duration = .seconds(5)
    ) {
        self.title = title
        self.answer = answer
        self.answerHint = answerHint
        self.shape = shape
        self.shapeAspectRatio = shapeAspectRatio
        self.pathAnimationType = pathAnimationType
        self.questionDrawingDuration = questionDrawingDuration
        self.answerDrawingDuration = answerDrawingDuration
    }

    public init(title: String, symbolInfo: SymbolInfo) {
        self.title = title
        answer = symbolInfo.answer
        answerHint = symbolInfo.answerHint
        shape = symbolInfo.shape
        shapeAspectRatio = symbolInfo.aspectRatio
        pathAnimationType = symbolInfo.pathAnimationType
        questionDrawingDuration = symbolInfo.questionDrawingDuration
        answerDrawingDuration = symbolInfo.answerDrawingDuration
    }

    public var body: some View {
        SymbolQuizView(
            titleContent: {
                Text(title)
                    .font(.largeFont)
                    .foregroundStyle(.themeColor)
            }, answerPrefixContent: {
                Text("正解:")
                    .font(.mediumFont)
                    .foregroundStyle(.defaultForegroundColor)
            }, answerContent: {
                Text(answer)
                    .font(.largeFont)
                    .foregroundStyle(.strokeColor)
            }, showAnswerContent: {
                Text("正解を表示")
                    .font(.mediumFont)
                    .foregroundStyle(.defaultForegroundColor)
            }, answerHintContent: {
                Text(answerHint ?? "")
                    .font(.mediumFont)
                    .foregroundStyle(.defaultForegroundColor)
            },
            shape: shape,
            shapeAspectRatio: shapeAspectRatio,
            questionDrawingDuration: questionDrawingDuration, answerDrawingDuration: answerDrawingDuration, pathAnimationType: pathAnimationType
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.slideBackgroundColor)
    }
}

#Preview {
    SlidePreview {
        QuizAnimationSlide(
            title: "Sample Question",
            answer: "Sugiy",
            answerHint: "Hint",
            shape: SugiyShape(),
            shapeAspectRatio: 974 / 648
        )
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
