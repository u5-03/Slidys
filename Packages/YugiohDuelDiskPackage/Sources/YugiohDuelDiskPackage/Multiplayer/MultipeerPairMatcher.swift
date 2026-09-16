//
//  MultipeerPairMatcher.swift
//  YugiohDuelDiskPackage
//
//  「ペア名」による相手の絞り込み判定。同じ部屋に多数のデバイス(例: Vision Pro 6 台 = 3 ペア)が
//  いても、同じペア名を入力した者同士だけが接続されるようにする。
//  - host: 広告の discoveryInfo にペア名を載せ、招待の context に載ってきたペア名が一致するときだけ受諾する。
//  - guest: `foundPeer` の discoveryInfo にあるペア名が一致するホストだけを招待し、招待 context に自分のペア名を載せる。
//  判定は両側で `sanitizedPairName` を通した完全一致(空文字 "" = ペア名なし は "" とだけ一致)。
//  MultipeerConnectivity に依存しないので、実機なしで単体テストできる。
//

import Foundation

public enum MultipeerPairMatcher {
    /// discoveryInfo / 招待 context に載せるペア名のキー。
    public static let pairInfoKey = "pair"
    /// discoveryInfo に載せる表示名のキー(デバッグ用。判定には使わない)。
    public static let nameInfoKey = "name"
    /// ペア名の上限(Character 数)。Bonjour TXT レコードに載るため短く保つ。
    public static let maxPairNameCharacters = 20

    /// ペア名を整える: 前後の空白・改行を除き、20 文字(Character 単位)を超える分は末尾から削る。
    /// 日本語などはそのまま許可する。空文字は「ペア名なし」を意味する。
    public static func sanitizedPairName(_ pairName: String) -> String {
        let trimmed = pairName.trimmingCharacters(in: .whitespacesAndNewlines)
        return String(trimmed.prefix(maxPairNameCharacters))
    }

    /// host の広告(discoveryInfo)からペア名を取り出す。nil / キーなしは "" として扱う。
    public static func pairName(fromDiscoveryInfo info: [String: String]?) -> String {
        sanitizedPairName(info?[pairInfoKey] ?? "")
    }

    /// guest の招待 context(UTF-8 のペア名)からペア名を取り出す。nil / 解釈不能は "" として扱う。
    public static func pairName(fromInvitationContext context: Data?) -> String {
        guard let context, let text = String(data: context, encoding: .utf8) else { return "" }
        return sanitizedPairName(text)
    }

    /// 自分と相手のペア名が一致するか(両側を `sanitizedPairName` に通した完全一致)。
    public static func matches(local: String, remote: String) -> Bool {
        sanitizedPairName(local) == sanitizedPairName(remote)
    }

    /// guest が招待に添える context(UTF-8 のペア名)。
    public static func invitationContext(for pairName: String) -> Data {
        Data(sanitizedPairName(pairName).utf8)
    }

    /// host が広告に載せる discoveryInfo。値は短く保つ(Bonjour TXT レコードの制限)。
    public static func discoveryInfo(pairName: String, displayName: String) -> [String: String] {
        [pairInfoKey: sanitizedPairName(pairName), nameInfoKey: displayName]
    }
}
