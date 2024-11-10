//
//  SymbolType.swift
//  KanagawaSwiftSlide
//
//  Created by Yugo Sugiyama on 2024/11/02.
//

import SwiftUI

enum SymbolType {
    case train
    case kamaboko
    case car
    case kirara
    case enoshima

    var quizIndex: Int {
        switch self {
        case .train: return 1
        case .kamaboko: return 2
        case .car: return 3
        case .kirara: return 4
        case .enoshima: return 5
        }
    }

    var answer: String {
        switch self {
        case .train: return "ロマンスカー"
        case .kamaboko: return "かまぼこ"
        case .car: return "日産 セレナ"
        case .kirara: return "DB. キララ"
        case .enoshima: return "江ノ島"
        }
    }

    var answerHint: String {
        switch self {
        case .train: return ""
        case .kamaboko: return ""
        case .car: return "〇〇 〇〇〇"
        case .kirara: return ""
        case .enoshima: return ""
        }
    }

    var aspectRatio: CGFloat {
        switch self {
        case .train: return 433 / 395
        case .kamaboko: return 460 / 355
        case .car: return 546 / 297
        case .kirara: return 203 / 159
        case .enoshima: return 990 / 617
        }
    }

    var shape: any Shape {
        switch self {
        case .train: return TrainShape()
        case .kamaboko: return KamabokoShape()
        case .car: return CarShape()
        case .kirara: return KiraraShape()
        case .enoshima: return EnoshimaShape()
        }
    }
}
