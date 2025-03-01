//
//  SampleCardModel.swift
//  SlidysCore
//
//  Created by Yugo Sugiyama on 2025/03/01.
//

import YugiohCardEffect
import SwiftUI

extension CardModel {
    static let chibaCard: CardModel = .init(
        name: "千葉のモンスター",
        attribute: "D",
        starCount: 4,
        imageType: .shape(shape: UhooiShape(), aspectRatio: 880 / 617),
        imageBackgroundColor: Color(hex: "B2E6A7"),
        species: "ポケカ",
        description: "某惑星から都内某所へ出向いて働いているエンジニア。Swiftとポケカを愛するアクティブなモンスター",
        attackPoint: 1900,
        defencePoint: 1600
    )

    static let kanagawaCard: CardModel = .init(
        name: "神奈川のマスコット",
        attribute: "D",
        starCount: 3,
        imageType: .shape(shape: KiraraShape(), aspectRatio: 880 / 617),
        imageBackgroundColor: Color(hex: "E48D02"),
        species: "スポーツ",
        description: "どこかのチームに所属する可愛らしいマスコットキャラクター。ダンスが得意で、あるキャラから一目惚れされている恋の行方も気になるキャラクター。",
        attackPoint: 1000,
        defencePoint: 1000
    )

    static let osakaCard: CardModel = .init(
        name: "大阪のお弁当",
        attribute: "食",
        starCount: 4,
        imageType: .shape(shape: BentoShape(), aspectRatio: 579 / 361),
        imageBackgroundColor: Color.white,
        species: "ランチ",
        description: "生の筍を下処理して鰹節と昆布から出汁を取って炊いた筍ご飯をメインに、鮭と卵焼きが添えられたお弁当。非常に手間がかかった美味しそうなお弁当。召喚に成功した時、自分のライフを1000回復する。",
        attackPoint: 1000,
        defencePoint: 3000
    )

    static let minokamoCard: CardModel = .init(
        name: "岐阜のとある将軍",
        attribute: "武",
        starCount: 8,
        imageType: .shape(shape: NobunagaShape(), aspectRatio: 1015 / 1192),
        imageBackgroundColor: Color(hex: "6E8A65"),
        species: "戦士",
        description: "Uhooi星から都内某所へ出向いて働いているエンジニア。Swiftとポケカを愛するアクティブなモンスター",
        attackPoint: 3000,
        defencePoint: 2000
    )
}

#Preview {
    CardView(card: .chibaCard)
    CardView(card: .kanagawaCard)
    CardView(card: .osakaCard)
    CardView(card: .minokamoCard)
}
