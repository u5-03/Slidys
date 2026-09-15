//
//  DuelCard+Wire.swift
//  YugiohDuelDiskPackage
//
//  ピアから受信したカードの無害化。
//  受信側の描画(`CardView` の `ForEach(0..<starCount)` など)は値域を前提にしているため、
//  相手が送ってきた値をそのまま Store に入れると、負の level でクラッシュ / 巨大な level でハングし得る。
//  `DuelSessionStore.applyOpponentEvent` はすべてのカードに `sanitizedForWire()` を通してから保存する。
//

import Foundation

/// ワイヤー経由で受け取る値の上限。描画側の前提(星の数 / 表示桁数など)に合わせる。
public enum DuelWireLimits {
    /// モンスターのレベル(星の数)。
    public static let levelRange: ClosedRange<Int> = 0...12
    /// 攻撃力 / 守備力。
    public static let statRange: ClosedRange<Int> = 0...99_999
    /// カードビジュアルのバリエーション(0: あんこフォルム / 1: デスマーチ)。
    public static let artVariantRange: ClosedRange<Int> = 0...1
    /// カードの各文字列フィールド(name / attribute / species / text / symbolName)の最大文字数。
    public static let maxCardStringLength: Int = 200
    /// ピア情報(displayName / deviceKind)の最大文字数。
    public static let maxPeerStringLength: Int = 64
    /// 1 メッセージの最大バイト数。これを超える受信データはデコードせずに捨てる。
    public static let maxPayloadBytes: Int = 64 * 1024

    /// 先頭 `maxLength` 文字に切り詰める(Character 単位なので結合文字を分断しない)。
    static func truncated(_ string: String, to maxLength: Int) -> String {
        string.count <= maxLength ? string : String(string.prefix(maxLength))
    }

    static func clamped(_ value: Int, to range: ClosedRange<Int>) -> Int {
        min(max(value, range.lowerBound), range.upperBound)
    }
}

public extension DuelCard {
    /// 受信したカードを描画に安全な値域へ丸めたコピーを返す。
    /// - `level` → 0...12 / `attack` `defense` → 0...99_999 / `artVariant` → 0...1
    /// - 文字列フィールドは 200 文字に切り詰める
    /// `id` / `isRare` / `flavor` / `summonModel` はそのまま保持する。
    func sanitizedForWire() -> DuelCard {
        let maxLength = DuelWireLimits.maxCardStringLength
        switch self {
        case .monster(let monster):
            return .monster(
                MonsterCard(
                    id: monster.id,
                    name: DuelWireLimits.truncated(monster.name, to: maxLength),
                    attribute: DuelWireLimits.truncated(monster.attribute, to: maxLength),
                    level: DuelWireLimits.clamped(monster.level, to: DuelWireLimits.levelRange),
                    species: DuelWireLimits.truncated(monster.species, to: maxLength),
                    text: DuelWireLimits.truncated(monster.text, to: maxLength),
                    attack: DuelWireLimits.clamped(monster.attack, to: DuelWireLimits.statRange),
                    defense: DuelWireLimits.clamped(monster.defense, to: DuelWireLimits.statRange),
                    isRare: monster.isRare,
                    artVariant: DuelWireLimits.clamped(monster.artVariant, to: DuelWireLimits.artVariantRange),
                    flavor: monster.flavor,
                    summonModel: monster.summonModel
                )
            )
        case .spell(let spell):
            return .spell(
                SpellCard(
                    id: spell.id,
                    name: DuelWireLimits.truncated(spell.name, to: maxLength),
                    text: DuelWireLimits.truncated(spell.text, to: maxLength),
                    symbolName: DuelWireLimits.truncated(spell.symbolName, to: maxLength)
                )
            )
        case .trap(let trap):
            return .trap(
                TrapCard(
                    id: trap.id,
                    name: DuelWireLimits.truncated(trap.name, to: maxLength),
                    text: DuelWireLimits.truncated(trap.text, to: maxLength),
                    symbolName: DuelWireLimits.truncated(trap.symbolName, to: maxLength)
                )
            )
        }
    }
}

public extension DuelPeerInfo {
    /// 受信したピア情報の文字列を 64 文字に切り詰めたコピーを返す。
    func sanitizedForWire() -> DuelPeerInfo {
        let maxLength = DuelWireLimits.maxPeerStringLength
        return DuelPeerInfo(
            displayName: DuelWireLimits.truncated(displayName, to: maxLength),
            deviceKind: DuelWireLimits.truncated(deviceKind, to: maxLength)
        )
    }
}
