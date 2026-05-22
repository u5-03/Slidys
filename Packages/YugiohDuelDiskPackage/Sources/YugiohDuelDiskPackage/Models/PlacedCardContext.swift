//
//  PlacedCardContext.swift
//  YugiohDuelDiskPackage
//
//  配置済みカードの「どこに置かれているか」を表現する識別子。
//

import Foundation

public enum PlacedCardContext: Hashable, Sendable {
    /// ディスク上の召喚スロット(0〜4)
    case diskSlot(Int)
    /// 召喚エリア奥列(0〜4)
    case arenaBack(Int)
    /// 召喚エリア手前列(0〜4) — 将来用
    case arenaFront(Int)
}
