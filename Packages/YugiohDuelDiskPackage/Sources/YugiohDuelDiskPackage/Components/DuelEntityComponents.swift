//
//  DuelEntityComponents.swift
//  YugiohDuelDiskPackage
//
//  Entity に「これは何のオブジェクトか」「どの ID か」を持たせるための Component 群。
//  Entity 名(String) に ID を埋め込む方式は壊れやすいため、Component を SoT にする。
//
//  RealityKit の Component は `Component` プロトコル準拠 + `registerComponent()` 呼び出しが必要だが、
//  visionOS 26 では暗黙登録される。
//

#if os(visionOS)
import Foundation
import RealityKit

/// カード(扇手札 / 右手 / ディスク配置 / アリーナ配置 すべて) に付与する識別 Component。
public struct CardIdentityComponent: Component {
    public var id: UUID
    public init(id: UUID) { self.id = id }
}

/// ディスク上の召喚スロット(横並び5枚)に付与する index Component。
public struct DiskSlotIndexComponent: Component {
    public var index: Int
    public init(index: Int) { self.index = index }
}

/// 右人差し指 Tip の衝突プローブを区別するためのマーカー Component。
public struct RightIndexProbeComponent: Component {
    public init() {}
}

/// 右親指 Tip の衝突プローブを区別するためのマーカー Component。
public struct RightThumbProbeComponent: Component {
    public init() {}
}

/// デッキ Entity を識別するためのマーカー Component。
/// 名前文字列 ("DuelDeck") に頼らず Component で判定するため。
public struct DeckMarkerComponent: Component {
    public init() {}
}

/// 配置済みカード (ディスクスロット / 召喚エリア奥 / 召喚エリア手前) の
/// 「どこに配置されたか」を Entity 側に保持する Component。
/// タップ時に `PlacedCardContext` を確実に取り出すために使う。
public struct PlacedCardLocationComponent: Component {
    public enum Location: Hashable, Sendable {
        case diskSlot(Int)
        case arenaBack(Int)
        case arenaFront(Int)
    }
    public var location: Location
    public init(location: Location) { self.location = location }
}
#endif
