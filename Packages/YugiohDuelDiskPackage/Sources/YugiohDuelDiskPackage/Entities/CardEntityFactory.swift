//
//  CardEntityFactory.swift
//  YugiohDuelDiskPackage
//
//  カード本体を生成するファクトリ。
//  見た目の attachment 差し込みは View 側で行うため、ここでは土台 Entity のみを作る。
//

import Foundation
#if os(visionOS)
import RealityKit
import SwiftUI
import YugiohCardEffect

public enum CardEntityFactory {
    public static func make(model: DuelCard) -> Entity {
        let root = Entity()
        root.name = "Card_\(model.id.uuidString)"

        // 触り判定と hover は root 側に持たせる。
        root.components.set(InputTargetComponent())
        root.components.set(HoverEffectComponent())
        root.components.set(CardIdentityComponent(id: model.id))
        return root
    }
}

/// `DuelCard` を、見た目描画用の `YugiohCardEffect.CardModel` に変換するファクトリ。
public enum DuelCardVisualFactory {
    public static let designWidth: Float = 590
    public static let designHeight: Float = 860

    public static func visualModel(for card: DuelCard) -> YugiohCardEffect.CardModel {
        switch card {
        case .monster(let monster):
            // カードにモンスターの種類(抹茶/クリーム/…)が分かるよう、実データから組み立てる。
            // 画像は後で差し替え予定のため、種類ごとに色分けした仮アイコン(SF Symbol)を使う。
            return YugiohCardEffect.CardModel(
                name: monster.name,
                attribute: monster.attribute,
                starCount: monster.level,
                imageType: .image(image: Image(systemName: "fish.fill"), aspectRatio: 1),
                imageBackgroundColor: flavorColor(monster.flavor),
                species: monster.species,
                description: monster.text,
                attackPoint: monster.attack,
                defencePoint: monster.defense,
                isRare: monster.isRare,
                kind: .monster
            )
        case .spell(let spell):
            return YugiohCardEffect.CardModel(
                name: spell.name,
                attribute: "",
                starCount: 0,
                imageType: .image(image: Image(systemName: spell.symbolName), aspectRatio: 1),
                imageBackgroundColor: Color(red: 0.80, green: 0.95, blue: 0.88),
                species: "",
                description: spell.text,
                attackPoint: 0,
                defencePoint: 0,
                isRare: false,
                kind: .spell
            )
        case .trap(let trap):
            return YugiohCardEffect.CardModel(
                name: trap.name,
                attribute: "",
                starCount: 0,
                imageType: .image(image: Image(systemName: trap.symbolName), aspectRatio: 1),
                imageBackgroundColor: Color(red: 0.95, green: 0.86, blue: 0.93),
                species: "",
                description: trap.text,
                attackPoint: 0,
                defencePoint: 0,
                isRare: false,
                kind: .trap
            )
        }
    }

    /// たい焼きの具材ごとのカード画像背景色(種類が一目で分かるように色分け)。
    static func flavorColor(_ flavor: TaiyakiFlavor) -> Color {
        switch flavor {
        case .matcha: return Color(red: 0.66, green: 0.82, blue: 0.55)      // 抹茶(緑)
        case .cream: return Color(red: 0.98, green: 0.93, blue: 0.72)       // クリーム(淡黄)
        case .chocolate: return Color(red: 0.55, green: 0.40, blue: 0.28)   // チョコ(茶)
        case .redBean: return Color(red: 0.78, green: 0.45, blue: 0.50)     // あんこ(小豆色)
        }
    }
}
#endif
