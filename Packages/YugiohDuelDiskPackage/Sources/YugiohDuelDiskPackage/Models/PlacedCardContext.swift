//
//  PlacedCardContext.swift
//  YugiohDuelDiskPackage
//
//  配置済みカードの「どこに置かれているか」を表現する識別子。
//

import Foundation

public enum PlacedCardContext: Hashable, Sendable {
    /// ディスク上の召喚スロット(0〜4) — モンスター
    case diskSlot(Int)
    /// ディスク上の魔法・トラップ挿入口(0〜4) — 魔法 / トラップ
    case spellSlot(Int)
    /// フィールド奥列(0〜4) — モンスター
    case fieldBack(Int)
    /// フィールド手前列(0〜4) — 魔法 / トラップ
    case fieldFront(Int)
}

// realitytool のスキーマ走査を避けるため extension で Codable を付与(DuelCard.swift 参照)。
extension PlacedCardContext: Codable {}
