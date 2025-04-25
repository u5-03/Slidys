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
struct NagoyaQuizAnimationSlide: View {
    let symbolInfo: SymbolInfo

    var body: some View {
        QuizAnimationSlide(
            title: "愛知シンボルクイズ 第\(symbolInfo.quizIndex)問",
            symbolInfo: symbolInfo
        )
    }
}

#Preview {
    SlidePreview {
        NagoyaQuizAnimationSlide(symbolInfo: SymbolType.nobunaga)
    }
}

