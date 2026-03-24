//
//  Created by yugo.sugiyama on 2025/04/07
//  Copyright ©Sugiy All rights reserved.
//

import SwiftUI
import SymbolKit

public struct SymbolQuizSampleView: View {
    let title: String
    let answer: String
    let answerHint: String
    let shape: any Shape
    let shapeAspectRatio: CGFloat
    let lineWidth: CGFloat
    let questionDrawingDuration: Duration
    let answerDrawingDuration: Duration
    let pathAnimationType: PathAnimationType

    public init(title: String, answer: String, answerHint: String, shape: any Shape, shapeAspectRatio: CGFloat, lineWidth: CGFloat = 4, questionDrawingDuration: Duration, answerDrawingDuration: Duration, pathAnimationType: PathAnimationType) {
        self.title = title
        self.answer = answer
        self.answerHint = answerHint
        self.shape = shape
        self.shapeAspectRatio = shapeAspectRatio
        self.lineWidth = lineWidth
        self.questionDrawingDuration = questionDrawingDuration
        self.answerDrawingDuration = answerDrawingDuration
        self.pathAnimationType = pathAnimationType
    }

    public var body: some View {
        SymbolQuizView(
            titleContent: {
                Text(title)
                    .font(.largeFont)
                    .foregroundStyle(.themeColor)
            }, answerPrefixContent: {
                Text("A:")
                    .font(.mediumFont)
                    .foregroundStyle(.defaultForegroundColor)
            }, answerContent: {
                Text(answer)
                    .font(.largeFont)
                    .foregroundStyle(.strokeColor)
            }, showAnswerContent: {
                Text("Show Answer")
                    .font(.mediumFont)
                    .foregroundStyle(.defaultForegroundColor)
            }, answerHintContent: {
                Text(answerHint)
                    .font(.mediumFont)
                    .foregroundStyle(.defaultForegroundColor)
            }, answerAlternativeContent: nil,
            shape: shape,
            shapeAspectRatio: shapeAspectRatio,
            lineWidth: lineWidth,
            questionDrawingDuration: questionDrawingDuration, answerDrawingDuration: answerDrawingDuration, pathAnimationType: pathAnimationType
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.slideBackgroundColor)
    }
}

#Preview {
    SymbolQuizSampleView(
        title: "Title",
        answer: "Answer",
        answerHint: "",
        shape: MtFujiShape(),
        shapeAspectRatio: MtFujiShape.aspectRatio,
        questionDrawingDuration: .seconds(12),
        answerDrawingDuration: .seconds(5),
        pathAnimationType: .progressiveDraw
    )
}
