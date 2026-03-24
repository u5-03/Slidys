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
    case daruma
    case bento
    case usj

    var quizIndex: Int {
        switch self {
        case .daruma: return 1
        case .bento: return 2
        case .usj: return 3
        }
    }

    var answer: String {
        switch self {
        case .daruma: return "串カツだるまのだるま大臣"
        case .bento: return "ととさんのお弁当"
        case .usj: return "UniversalStudioJapan"
        }
    }

    var answerHint: String {
        switch self {
        case .daruma: return ""
        case .bento: return "〇〇さんのお〇〇"
        case .usj: return ""
        }
    }

    var aspectRatio: CGFloat {
        switch self {
        case .daruma: return 103 / 344
        case .bento: return 579 / 361
        case .usj: return 546 / 297
        }
    }

    var shape: any Shape {
        switch self {
        case .daruma:
            return DarumaShape()
        case .bento:
            return BentoShape()
        case .usj:
            return TextPathShape(
                "UniversalStudioJapan",
                textAnimationOrder: .random
            )
        }
    }
}
