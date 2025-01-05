//
//  SymbolType.swift
//  KanagawaSwiftSlide
//
//  Created by Yugo Sugiyama on 2024/11/02.
//

import SwiftUI
import SymbolKit

enum SymbolType {
    case myakumyaku
    case bento
    case usj

    var quizIndex: Int {
        switch self {
        case .myakumyaku: return 1
        case .bento: return 2
        case .usj: return 3
        }
    }

    var answer: String {
        switch self {
        case .myakumyaku: return "ミャクミャク"
        case .bento: return "ととさんのお弁当"
        case .usj: return "UniversalStudioJapan"
        }
    }

    var answerHint: String {
        switch self {
        case .myakumyaku: return ""
        case .bento: return "〇〇さんのお〇〇"
        case .usj: return ""
        }
    }

    var aspectRatio: CGFloat {
        switch self {
        case .myakumyaku: return 433 / 395
        case .bento: return 460 / 355
        case .usj: return 546 / 297
        }
    }

    var shape: any Shape {
        switch self {
        case .myakumyaku:
            return TrainShape()
        case .bento:
            return KamabokoShape()
        case .usj:
            return TextPathShape(
                "UniversalStudioJapan",
                textAnimationOrder: .random
            )
        }
    }
}
