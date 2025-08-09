//
//  KanagawaQuizAnimationSlide.swift
//
//
//  Created by Yugo Sugiyama on 2024/11/10.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct KanagawaQuizAnimationSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    let symbolType: SymbolType

    var body: some View {
        QuizAnimationSlide(
            title: "神奈川シンボルクイズ 第\(symbolType.quizIndex)問",
            answer: symbolType.answer,
            answerHint: symbolType.answerHint,
            shape: symbolType.shape,
            shapeAspectRatio: symbolType.aspectRatio
        )
    }
}

#Preview {
    SlidePreview {
        KanagawaQuizAnimationSlide(symbolType: .train)
    }
}

