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
struct MinokamoQuizAnimationSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    let symbolInfo: SymbolInfo

    var body: some View {
        QuizAnimationSlide(
            title: "岐阜シンボルクイズ 第\(symbolInfo.quizIndex)問",
            symbolInfo: symbolInfo
        )
    }
}

#Preview {
    SlidePreview {
        MinokamoQuizAnimationSlide(symbolInfo: SymbolType.nobunaga)
    }
}

