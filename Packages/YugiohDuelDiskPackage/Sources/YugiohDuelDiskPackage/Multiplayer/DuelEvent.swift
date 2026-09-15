//
//  DuelEvent.swift
//  YugiohDuelDiskPackage
//
//  対戦モードでピア間を流れるワイヤーモデル。
//  デバイス非依存(macOS / iOS / visionOS)で、JSON にエンコードして送受信する。
//

import Foundation

// NOTE: 各型の `Codable` は型宣言の継承句ではなくファイル末尾の extension で付与している。
// `.rkassets` を持つターゲットでは realitytool が継承句に Codable を持つ型をスキーマ走査し、
// associated value 付き enum でビルドエラーになるため(DuelCard.swift 参照)。

/// フィールドの列。`back` = 奥列(モンスター) / `front` = 手前列(魔法・トラップ)。
public enum DuelFieldRow: String, Sendable, Hashable {
    case back
    case front
}

/// ピア(対戦相手 / 自分)の識別情報。
public struct DuelPeerInfo: Sendable, Equatable {
    public var displayName: String
    /// "visionOS" / "iOS" / "macOS"
    public var deviceKind: String

    public init(displayName: String, deviceKind: String) {
        self.displayName = displayName
        self.deviceKind = deviceKind
    }
}

/// 送信者のフィールド全体のスナップショット。接続直後の同期に使う。
public struct DuelFieldSnapshot: Sendable, Equatable {
    public var backRow: [DuelCard?]
    public var frontRow: [DuelCard?]
    public var frontRevealed: [Bool]

    public init(backRow: [DuelCard?], frontRow: [DuelCard?], frontRevealed: [Bool]) {
        self.backRow = backRow
        self.frontRow = frontRow
        self.frontRevealed = frontRevealed
    }
}

/// 送信者「自身の」盤面に対する出来事。受信側は自分の opponent 側へ適用する。
public enum DuelEvent: Sendable, Equatable {
    case hello(DuelPeerInfo)
    case snapshot(DuelFieldSnapshot)
    case summonMonster(slot: Int, card: DuelCard)
    /// 裏向きで置く
    case setSpellOrTrap(slot: Int, card: DuelCard)
    /// front row を表にする
    case openCard(slot: Int)
    case removeCard(row: DuelFieldRow, slot: Int)
    /// 送信者が盤面リセット
    case newDuel
}

/// バージョン付きのワイヤーメッセージ。
public struct DuelWireMessage: Sendable {
    public static let currentVersion = 1

    public var version: Int
    public var event: DuelEvent

    public init(version: Int = DuelWireMessage.currentVersion, event: DuelEvent) {
        self.version = version
        self.event = event
    }
}

// MARK: - Codable(extension 経由。理由はファイル冒頭の NOTE 参照)

extension DuelFieldRow: Codable {}
extension DuelPeerInfo: Codable {}
extension DuelFieldSnapshot: Codable {}
extension DuelEvent: Codable {}
extension DuelWireMessage: Codable {}

/// `version` だけを先に読むための最小構造。未対応バージョンを、ペイロード(未知の enum case など)の
/// デコード失敗より先に「バージョン不一致」として報告するために使う。
private struct DuelWireVersionProbe {
    let version: Int
}

extension DuelWireVersionProbe: Decodable {}

/// `DuelEvent` <-> `Data` の変換。JSON を用い、未対応バージョンは拒否する。
public enum DuelWireCodec {
    public enum CodecError: Error, Equatable, Sendable {
        case unsupportedVersion(Int)
    }

    public static func encode(_ event: DuelEvent) throws -> Data {
        let message = DuelWireMessage(event: event)
        return try JSONEncoder().encode(message)
    }

    /// バージョンを先に検証してから本体をデコードする。
    /// - 不正 JSON / `version` 欠落: `DecodingError`
    /// - 未対応バージョン: `CodecError.unsupportedVersion`(ペイロード内容は見ない)
    public static func decode(_ data: Data) throws -> DuelEvent {
        let decoder = JSONDecoder()
        let probe = try decoder.decode(DuelWireVersionProbe.self, from: data)
        guard probe.version == DuelWireMessage.currentVersion else {
            throw CodecError.unsupportedVersion(probe.version)
        }
        let message = try decoder.decode(DuelWireMessage.self, from: data)
        return message.event
    }
}
