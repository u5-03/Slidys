//
//  Created by yugo.sugiyama on 2025/03/16
//  Copyright ©Sugiy All rights reserved.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct TrySwiftSymbolQuizSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        QuizAnimationSlide(
            title: "Japan Symbol Quiz!",
            symbolInfo: .init(
                quizIndex: 1,
                answer: "Cherry blossoms",
                aspectRatio: CherryBlossomsShape.aspectRatio,
                shape: CherryBlossomsShape(),
                questionDrawingDuration: .seconds(50),
                answerDrawingDuration: .seconds(5),
                lineWidth: 3,
                answerAlternativeContent: AnyView(
                    CherryBlossomsAnswerView()
                )
            )
        )
    }
}

#Preview {
    TrySwiftSymbolQuizSlide()
}
