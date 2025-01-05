//
//  KanagawaQuizAnimationSlide.swift
//
//
//  Created by Yugo Sugiyama on 2024/11/10.
//

import SwiftUI
import SlideKit

@Slide
struct OsakaQuizAnimationSlide: View {
    let symbolType: SymbolType

    var body: some View {
        QuizAnimationSlide(
            title: "大阪シンボル？クイズ 第\(symbolType.quizIndex)問",
            answer: symbolType.answer,
            answerHint: symbolType.answerHint,
            shape: symbolType.shape,
            shapeAspectRatio: symbolType.aspectRatio
        )
    }
}

#Preview {
    SlidePreview {
        OsakaQuizAnimationSlide(symbolType: .myakumyaku)
    }
}

