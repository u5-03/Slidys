//
//  DuelCard.swift
//  YugiohDuelDiskPackage
//
//  デュエルで扱うカードのモデル。
//  種類ごとに表示情報を持つ struct を定義し (モンスター / 魔法 / トラップ)、
//  それらを associated value に持つ enum `DuelCard` で一元的に扱う。
//  手札や各スロットの配列はすべて `DuelCard` で保持する。
//

import Foundation

// MARK: - 種類ごとの表示情報

/// たい焼きモンスターの具材バリエーション。召喚時に表示する 3D オブジェクト(Filling_*)に対応。
public enum TaiyakiFlavor: String, CaseIterable, Sendable {
    case matcha      // 抹茶
    case cream       // クリーム
    case chocolate   // チョコレート
    case redBean     // あんこ

    /// Taiyaki.usdz 内の具材ノード名。
    public var fillingNodeName: String {
        switch self {
        case .matcha: return "Filling_Matcha"
        case .cream: return "Filling_Custard"
        case .chocolate: return "Filling_Chocolate"
        case .redBean: return "Filling_RedBeans"
        }
    }

    public var displayName: String {
        switch self {
        case .matcha: return "抹茶"
        case .cream: return "クリーム"
        case .chocolate: return "チョコレート"
        case .redBean: return "あんこ"
        }
    }
}

/// モンスターカードの表示情報。
public struct MonsterCard: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let name: String
    public let attribute: String
    public let level: Int
    public let species: String
    public let text: String
    public let attack: Int
    public let defense: Int
    public let isRare: Bool
    /// 既存の作り込まれたカードビジュアル(0: あんこフォルム / 1: デスマーチ)の選択。
    public let artVariant: Int
    /// 召喚時に表示するたい焼きの具材。
    public let flavor: TaiyakiFlavor

    public init(
        id: UUID = UUID(),
        name: String,
        attribute: String,
        level: Int,
        species: String,
        text: String,
        attack: Int,
        defense: Int,
        isRare: Bool = false,
        artVariant: Int = 0,
        flavor: TaiyakiFlavor = .redBean
    ) {
        self.id = id
        self.name = name
        self.attribute = attribute
        self.level = level
        self.species = species
        self.text = text
        self.attack = attack
        self.defense = defense
        self.isRare = isRare
        self.artVariant = artVariant
        self.flavor = flavor
    }
}

/// 魔法カードの表示情報。
public struct SpellCard: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let name: String
    public let text: String
    /// 仮画像用の SF Symbol 名。
    public let symbolName: String

    public init(id: UUID = UUID(), name: String, text: String, symbolName: String = "wand.and.stars") {
        self.id = id
        self.name = name
        self.text = text
        self.symbolName = symbolName
    }
}

/// トラップ(罠)カードの表示情報。
public struct TrapCard: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let name: String
    public let text: String
    /// 仮画像用の SF Symbol 名。
    public let symbolName: String

    public init(id: UUID = UUID(), name: String, text: String, symbolName: String = "exclamationmark.triangle.fill") {
        self.id = id
        self.name = name
        self.text = text
        self.symbolName = symbolName
    }
}

// MARK: - カード種別を包む enum

public enum DuelCard: Identifiable, Equatable, Sendable {
    case monster(MonsterCard)
    case spell(SpellCard)
    case trap(TrapCard)

    /// 種類の判別に使う軽量 enum。
    public enum Kind: Equatable, Sendable {
        case monster
        case spell
        case trap
    }

    public var id: UUID {
        switch self {
        case .monster(let card): return card.id
        case .spell(let card): return card.id
        case .trap(let card): return card.id
        }
    }

    public var kind: Kind {
        switch self {
        case .monster: return .monster
        case .spell: return .spell
        case .trap: return .trap
        }
    }

    /// 魔法・トラップ(=召喚エリアではなく魔法・トラップ挿入口に置くカード)か。
    public var isSpellOrTrap: Bool {
        switch self {
        case .monster: return false
        case .spell, .trap: return true
        }
    }

    public static func == (lhs: DuelCard, rhs: DuelCard) -> Bool {
        lhs.id == rhs.id && lhs.kind == rhs.kind
    }
}

// MARK: - サンプル / ランダム生成

public extension DuelCard {
    /// ドロー・初期手札で使うランダムなカードを1枚返す。
    /// モンスターを多めに、魔法・トラップを少量混ぜる。
    static func random() -> DuelCard {
        switch Int.random(in: 0..<10) {
        case 0, 1:
            return .spell(SpellCard.samples.randomElement()!)
        case 2, 3:
            return .trap(TrapCard.samples.randomElement()!)
        default:
            return .monster(MonsterCard.samples.randomElement()!)
        }
    }
}

public extension MonsterCard {
    /// たい焼きモンスター4種(具材違い)。カード画像は後で差し替え予定のため暫定。
    static var samples: [MonsterCard] {
        TaiyakiFlavor.allCases.enumerated().map { index, flavor in
            MonsterCard(
                name: "\(flavor.displayName)たい焼き",
                attribute: "甘",
                level: 4 + index,
                species: "甘党",
                text: "\(flavor.displayName)を包んだ焼きたてのたい焼きモンスター。香ばしい生地と\(flavor.displayName)の餡が特徴。",
                attack: 1200 + index * 300,
                defense: 1000 + index * 200,
                isRare: flavor == .redBean,
                artVariant: flavor == .redBean ? 1 : 0,
                flavor: flavor
            )
        }
    }
}

public extension SpellCard {
    static var samples: [SpellCard] {
        [
            SpellCard(name: "エナジードリンク", text: "自分フィールドのモンスター1体の攻撃力を、ターン終了時まで1000アップする。", symbolName: "bolt.fill"),
            SpellCard(name: "残業月80時間", text: "装備モンスターの攻撃力を2000アップするが、エンドフェイズに持ち主はライフを失う。", symbolName: "wand.and.stars"),
        ]
    }
}

public extension TrapCard {
    static var samples: [TrapCard] {
        [
            TrapCard(name: "急なアラート対応", text: "相手モンスターの攻撃を無効にし、その攻撃力分のダメージを相手に与える。", symbolName: "exclamationmark.triangle.fill"),
            TrapCard(name: "仕様変更", text: "相手が発動した効果を無効にして破壊する。", symbolName: "arrow.triangle.2.circlepath"),
        ]
    }
}
