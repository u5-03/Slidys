//
//  CardModel.swift
//  YugiohDuelDiskPackage
//

import Foundation

/// 1枚のカードを表す最小限のモデル。
/// 検証段階では識別子だけ持てば十分(カードフェイスは単色板のため)。
public struct CardModel: Identifiable, Hashable, Sendable {
    public let id: UUID

    public init(id: UUID = UUID()) {
        self.id = id
    }
}
