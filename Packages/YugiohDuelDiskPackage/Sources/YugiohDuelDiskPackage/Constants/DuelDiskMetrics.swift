//
//  DuelDiskMetrics.swift
//  YugiohDuelDiskPackage
//
//  デュエルディスク体験で使う寸法の定数。
//  単位はすべて meter (RealityKit 標準)。
//

import Foundation
import simd

public enum DuelDiskMetrics {
    // MARK: - ボード(腕に装着するディスク本体)

    /// ボードの横幅 (X): 30cm
    public static let boardWidth: Float = 0.30
    /// ボードの厚さ (Y): 1cm
    public static let boardThickness: Float = 0.01
    /// ボードの奥行き (Z): 15cm
    public static let boardDepth: Float = 0.15

    // MARK: - カード

    /// カード横幅 (X): 約58mm
    public static let cardWidth: Float = 0.058
    /// カード奥行き (Z): 約88mm
    public static let cardDepth: Float = 0.088
    /// カード厚み (Y): 0.3mm
    public static let cardThickness: Float = 0.0003

    // MARK: - デッキ

    /// 40枚分の厚みを基準にしたデッキの高さ
    public static let deckCardCount: Int = 40
    /// デッキの高さ = 40枚 × カード厚み = 0.012m
    public static var deckHeight: Float { Float(deckCardCount) * cardThickness }

    // MARK: - ディスク上の召喚スロット

    /// 1スロットの横幅 (X)
    public static let diskSlotWidth: Float = 0.05
    /// 1スロットの奥行き (Z)
    public static let diskSlotDepth: Float = 0.07
    /// スロット間ギャップ
    public static let diskSlotGap: Float = 0.005
    /// スロットの個数(横並び)
    public static let diskSlotCount: Int = 5

    // MARK: - 召喚エリア(地面)

    /// 召喚エリア1スロットの横幅
    public static let arenaSlotWidth: Float = 0.232
    /// 召喚エリア1スロットの奥行き
    public static let arenaSlotDepth: Float = 0.352
    /// 召喚エリアスロット間ギャップ (X方向)
    public static let arenaGapX: Float = 0.05
    /// 召喚エリア・奥列 (row 0) の Z (-) 方向距離 (m)
    public static let arenaBackZ: Float = -1.6
    /// 召喚エリア・手前列 (row 1) の Z (-) 方向距離 (m)
    public static let arenaFrontZ: Float = -1.2

    // MARK: - ジェスチャ判定

    /// ピンチ判定の距離 (親指Tip - 人差し指Tip 間) 5cm
    public static let pinchThreshold: Float = 0.05

    /// 選択中カードの持ち上げ量
    public static let selectedCardLift: Float = 0.005

    /// 右手指先プローブの衝突球半径
    public static let handTipProbeRadius: Float = 0.012

    // MARK: - 扇手札レイアウト

    /// 扇1枚あたりの広がり角度(度)
    public static let fanDegreesPerCard: Float = 8

    /// 扇カードを手のひらからどれだけ持ち上げて表示するか(基準位置)
    public static let fanBaseY: Float = 0.02

    /// 扇カードを手のひらからどれだけ奥に置くか
    public static let fanOffsetZ: Float = -0.05

    // MARK: - 召喚エフェクト

    /// カード召喚アニメの所要時間
    public static let cardRiseDuration: TimeInterval = 0.5

    /// カード召喚アニメで Y 方向にどれだけ浮かせるか
    public static let cardRiseHeight: Float = 0.05

    /// モンスター召喚までの待機時間
    public static let monsterSpawnDelay: TimeInterval = 1.0

    /// アリーナ上のカードのスケール倍率(=見やすさのため4倍に拡大)
    public static let arenaCardScale: Float = 4

    // MARK: - ピンチ polling

    /// ピンチ判定 polling の間隔(ナノ秒)。約 60fps。
    public static let pinchPollIntervalNanos: UInt64 = 16_000_000
}
