//
//  PhasedScript.swift
//  SlidesCore
//
//  フェーズ(項目の段階表示)を持つスライド用のスピーカーノート表現。
//  原稿をフェーズごとのセグメント配列で持ち、ノートWindowでは
//  セグメントの間に「ここで次を表示」の区切りを描画して、
//  スライド内で送りが必要な箇所を発表者に明示する。
//

import SlideKit

/// フェーズを持つスライドが、フェーズごとに区切った原稿を提供するためのプロトコル。
/// セグメント数はフェーズ数と揃える(先頭セグメント = 最初から表示される項目の説明)。
public protocol PhasedScriptProviding {
    var scriptSegments: [String] { get }
}

public extension Slide where Self: PhasedScriptProviding {
    /// 通常の script はセグメントを結合したもの(iPadのノートパネル等で使用)。
    var script: String { scriptSegments.joined(separator: "\n") }
}
