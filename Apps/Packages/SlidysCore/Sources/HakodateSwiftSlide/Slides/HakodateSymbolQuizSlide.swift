//
//  Created by yugo.sugiyama on 2026/02/22
//  Copyright ©Sugiy All rights reserved.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct HakodateSymbolQuizSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        QuizAnimationSlide(
            title: "Hokkaidoシンボル?クイズ",
            symbolInfo: .init(
                quizIndex: 1,
                answer: "チタタプしているアシリパさん",
                aspectRatio: AshiripaShape.aspectRatio,
                shape: AshiripaShape(),
                questionDrawingDuration: .seconds(15),
                answerDrawingDuration: .seconds(1)
            )
        )
    }
}

#Preview {
    SlidePreview {
        HakodateSymbolQuizSlide()
    }
}
