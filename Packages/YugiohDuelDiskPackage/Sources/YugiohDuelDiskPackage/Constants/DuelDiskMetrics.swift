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

    /// ボードの横幅 (X): 34cm
    public static let boardWidth: Float = 0.34
    /// ボードの厚さ (Y): 1cmJ
    public static let boardThickness: Float = 0.01
    /// ボードの奥行き (Z): 20cm
    public static let boardDepth: Float = 0.20

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

    /// 1スロットの横幅 (X) - カード実寸に揃える
    public static let diskSlotWidth: Float = cardWidth
    /// 1スロットの奥行き (Z) - カード実寸に揃える
    public static let diskSlotDepth: Float = cardDepth
    /// スロット間ギャップ
    public static let diskSlotGap: Float = 0.005
    /// スロットの個数(横並び)
    public static let diskSlotCount: Int = 5

    /// ディスクスロットに配置したカードを盤面からどれだけ垂直に浮かせるか
    public static let diskPlacedCardLift: Float = 0.012

    // MARK: - 召喚エリア(地面)

    /// 召喚エリア1スロットの横幅
    public static let fieldSlotWidth: Float = 0.464
    /// 召喚エリア1スロットの奥行き
    public static let fieldSlotDepth: Float = 0.704
    /// 召喚エリアスロット間ギャップ (X方向)
    public static let fieldGapX: Float = 0.10
    /// 召喚エリア・奥列 (row 0) の Z (-) 方向距離 (m)
    public static let fieldBackZ: Float = -1.8
    /// 召喚エリア・手前列 (row 1) の Z (-) 方向距離 (m)
    public static let fieldFrontZ: Float = -1.0
    /// 召喚エリアを地面から少し浮かせて埋まりを防ぐ高さ
    public static let fieldSurfaceHeight: Float = 0.015

    /// フィールド全体の拡大率(スロット・カード・モンスターをまとめて拡大)
    public static let fieldScale: Float = 3.0

    // MARK: - ジェスチャ判定

    /// ピンチ判定の距離 (親指Tip - 人差し指Tip 間) 5cm
    public static let pinchThreshold: Float = 0.05

    /// 選択中カードの持ち上げ量
    public static let selectedCardLift: Float = 0.005

    /// 右手指先プローブの衝突球半径
    public static let handTipProbeRadius: Float = 0.012

    /// 右手ピンチ中点で使うドロープローブ半径
    public static let drawProbeRadius: Float = 0.03

    /// デッキドロー用: 右手の人差し指Tip - 中指Tip が「くっついている」とみなす距離
    public static let drawFingerTouchThreshold: Float = 0.035

    /// 右手保持カード: 指先が「カード下端から1/3」の高さに重なるよう、
    /// 指先からカード中心までを上端方向にずらす距離 (h/2 - h/3 = h/6)
    public static var rightHandCardCenterOffset: Float { cardDepth / 2 - cardDepth / 3 }

    /// 右手の引いたカードを左手の扇へ取り込む近接距離
    public static let handoffDistanceThreshold: Float = 0.06

    // MARK: - 扇手札レイアウト

    /// 扇1枚あたりの広がり角度(度)
    public static let fanDegreesPerCard: Float = 8

    /// 扇カードの基準持ち上げ量。
    /// カード下端を指先に合わせるため、扇ルート原点(指先)からカード高さの半分だけ +Y に上げる。
    /// これで指とカードが重ならず全カードが見える。
    public static var fanBaseY: Float { cardDepth / 2 + 0.004 }

    /// 扇カードを手のひらからどれだけ奥に置くか
    public static let fanOffsetZ: Float = -0.05

    /// 扇カードを左右にどれだけ広げるか
    public static let fanSpreadX: Float = 0.03

    /// 扇カード1枚ごとの横方向オフセット
    public static let fanCardSpacing: Float = 0.026

    /// 扇カードの前後方向の段差
    public static let fanDepthStep: Float = 0.006

    /// 扇カードをピンチ中点からどれだけ前方に出すか
    public static let fanForwardOffset: Float = -0.03

    /// 扇カードをピンチ中点からどれだけ上方向にずらすか
    public static let fanVerticalOffset: Float = 0.01

    // MARK: - 召喚エフェクト

    /// カード召喚アニメの所要時間
    public static let cardRiseDuration: TimeInterval = 0.5

    /// カード召喚アニメで Y 方向にどれだけ浮かせるか
    public static let cardRiseHeight: Float = 0.05

    /// モンスター召喚までの待機時間
    public static let monsterSpawnDelay: TimeInterval = 1.0

    /// 召喚バースト(共通コントローラ)の拡大率。
    /// フィールドは 3x スケールなので、素材(約1m基準)を控えめに縮小して配置する。
    public static let summonBurstScale: Float = 0.3

    /// モンスター出現アニメ(フェードイン + 上昇)の所要時間
    public static let monsterRevealDuration: TimeInterval = 0.8

    /// モンスター出現時にどれだけ下から上昇して現れるか
    public static let monsterRevealRise: Float = 0.2

    /// アリーナ上のカードのスケール倍率(=見やすさのため4倍に拡大)
    public static let fieldCardScale: Float = 8
    /// ディスク上の召喚エフェクト平面の横幅
    public static let diskSummonEffectWidth: Float = 0.14
    /// ディスク上の召喚エフェクト平面の奥行き
    public static let diskSummonEffectDepth: Float = 0.18
    /// ディスク上の召喚エフェクト表示時間
    /// TODO(debug): デバッグ用に 10 倍スロー再生しているため表示時間も 10 倍にしている。確認後 1.2 に戻す。
    public static let diskSummonEffectDuration: TimeInterval = 1.2 * Double(diskSummonEffectDebugSlowMultiplier)

    /// TODO(debug): 召喚ライン伸長エフェクトのスロー再生倍率。確認後 1.0 に戻す。
    public static let diskSummonEffectDebugSlowMultiplier: Double = 10.0

    // MARK: - ピンチ polling

    /// ピンチ判定 polling の間隔(ナノ秒)。約 60fps。
    public static let pinchPollIntervalNanos: UInt64 = 16_000_000
}
