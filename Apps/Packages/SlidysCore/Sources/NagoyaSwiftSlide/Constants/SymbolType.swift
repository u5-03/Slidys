//
//  SymbolType.swift
//  KanagawaSwiftSlide
//
//  Created by Yugo Sugiyama on 2024/11/02.
//

import SwiftUI
import SymbolKit
import SlidesCore

enum SymbolType {
    static let worldHeritage = SymbolInfo(quizIndex: 2, answer: "白川郷・五箇山の合掌造り集落", aspectRatio: 546 / 297, shape: TextPathShape("TheHistoricVillagesOfShirakawaGoAndGokayama", textAnimationOrder: .random))
    static let raicho = SymbolInfo(quizIndex: 1, answer: "雷鳥", aspectRatio: 2439 / 1536, shape: RaichoShape(), questionDrawingDuration: .seconds(30))
    static let nobunaga = SymbolInfo(quizIndex: 3, answer: "織田信長", aspectRatio: 1015 / 1192, pathAnimationType: .fixedRatioMove(strokeLengthRatio: 0.08), shape: NobunagaShape())
}
