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

    /// ディスクスロットに配置したカードを盤面からどれだけ垂直に浮かせるか。
    /// ディスクにぴったり乗って見えるよう、Z-fight を避ける最小限だけ浮かせる。
    public static let diskPlacedCardLift: Float = 0.001

    /// ディスクスロットのタップ当たり判定の高さ (m)。
    /// 薄いと視線タップが当たりにくいため、スロット真上に十分な高さの判定を持たせる。
    public static let diskSlotTapHeight: Float = 0.09

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

    // MARK: - 召喚エリア操作ハンドル(右下の丸いハンドル)

    /// ハンドル球の半径 (m)。遠く(数m先)でも視認できるよう大きめ。
    public static let fieldHandleRadius: Float = 0.08
    /// ハンドル(角丸パネル)のサイズ (m)。球より "つまみ" らしく分かりやすい。
    public static let fieldHandleSize = SIMD3<Float>(0.16, 0.06, 0.16)
    /// 移動ハンドルの、フィールド中央からのワールドオフセット(手前=+Z, 右=+X, 上=+Y)。
    /// 召喚エリアの手前・中央やや右に、置き場と重ならないよう前に出す。
    public static let fieldMoveHandleOffset = SIMD3<Float>(0.35, 0.30, 1.6)
    /// 回転ハンドルの、フィールド中央からのワールドオフセット(手前・中央やや左)。
    public static let fieldRotateHandleOffset = SIMD3<Float>(-0.35, 0.30, 1.6)
    /// ハンドルの色の不透明度(存在感を弱めるため少し薄く)。
    public static let fieldHandleOpacity: Float = 0.5
    /// ハンドルの自己発光の強さ(薄めにして主張を抑える)。
    public static let fieldHandleEmissiveIntensity: Float = 0.5

    // MARK: - ジェスチャ判定

    /// ピンチ判定の距離 (親指Tip - 人差し指Tip 間) 5cm
    public static let pinchThreshold: Float = 0.05

    /// 3本指(手札表示)判定で「中指も確実にくっついている」とみなす距離。
    /// 2本指ピンチ(親指+人差し指)を誤って3本指と判定しないよう、pinchThreshold より厳しくする。
    public static let threeFingerThreshold: Float = 0.032

    /// 選択中カードの持ち上げ量
    public static let selectedCardLift: Float = 0.005

    // MARK: - 手札/右手カードのジッタ抑制(追従スムージング)

    /// 位置追従のローパス係数(小さいほど滑らか=手ブレを吸収するが少し遅延する)。
    public static let handFollowPositionAlpha: Float = 0.18
    /// 姿勢追従のローパス係数。
    public static let handFollowRotationAlpha: Float = 0.18
    /// この距離(m)未満の微小な目標変化は「手ブレ」とみなして無視する(静止時のプルプルを止める)。
    public static let handFollowPositionDeadband: Float = 0.0025
    /// この角度(rad, 約0.7°)未満の微小な姿勢変化は無視する。
    public static let handFollowRotationDeadband: Float = 0.012

    // MARK: - 手首追従(ディスク)の外れ値棄却

    /// 1tickで手首(ディスク)が移動しても許容する最大距離 (m)。
    /// これを超える移動だけを「極端なトラッキング飛び(テレポート)」とみなして保留する。
    /// 通常〜速い手の動き(素早い振りでも ~0.06m/tick=3.6m/s 程度)は追従を妨げないよう、余裕をもって 0.15 に設定。
    /// 60fps 想定で 0.15m/tick ≒ 9m/s 相当。
    public static let wristFollowMaxJumpPerTick: Float = 0.15

    /// 1tickで許容する最大回転角 (rad)。約46°。これを超える回転はグリッチとみなす。
    public static let wristFollowMaxAnglePerTick: Float = 0.8

    /// 大ジャンプがこのフレーム数以上続いたら、グリッチではなく実際の移動/再ローカライズと判断し追従を再開する。
    /// 60fps 想定で 3フレーム ≒ 50ms。瞬間的なグリッチだけ無視し、追従の遅れを最小化する。
    public static let wristFollowJumpConfirmFrames = 3

    /// 右手の指先がディスク中心からこの距離以内、かつディスク上面より上にあるときだけ手首追従を凍結する (m)。
    /// 「右手をディスク上へ伸ばしてタップ/配置している」状況に限定し、
    /// 通常の左手移動(右手が近くを通るだけ)では凍結しないようにする。
    public static let diskFollowFreezeRadius: Float = 0.16

    /// 右手指先プローブの衝突球半径
    public static let handTipProbeRadius: Float = 0.012

    /// 右手ピンチ中点で使うドロープローブ半径
    public static let drawProbeRadius: Float = 0.03

    /// デッキドロー用: 右手の人差し指Tip - 中指Tip が「くっついている」とみなす距離
    public static let drawFingerTouchThreshold: Float = 0.035

    /// 右手カードを「つまんで持っている(=表示する)」とみなす人差し指-中指の距離。
    /// ドロー判定より厳しめにして、指が離れているのに表示され続けるのを防ぐ。
    public static let rightHandCardHoldThreshold: Float = 0.028

    /// 右手に持ったカードがディスクのカード置き場に「重なった」とみなす距離 (m)。
    /// この距離以内にカード置き場が来たら、そのスロットに召喚する。
    public static let rightHandCardSummonRadius: Float = 0.09

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

    /// 扇カード1枚ごとの横方向オフセット。
    /// カード同士の重なりを減らして、各カードのタップ可能領域を広げる(選択精度向上)。
    public static let fanCardSpacing: Float = 0.040

    /// 扇カードの前後方向の段差。手前のカードほど確実に前面に来て、狙ったカードを選びやすくする。
    public static let fanDepthStep: Float = 0.010

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

    /// デモ用: ディスク配置からフィールド出現までの遅延(見逃し防止)
    public static let fieldSummonDelay: TimeInterval = 2.0

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
    public static let diskSummonEffectDuration: TimeInterval = 1.2 * diskSummonEffectSpeedMultiplier

    /// 召喚ライン伸長エフェクトの再生倍率(1.0 = 元の SwiftUI 実装と同じ速さ)。
    public static let diskSummonEffectSpeedMultiplier: Double = 1.0

    // MARK: - ピンチ polling

    /// ピンチ判定 polling の間隔(ナノ秒)。約 60fps。
    public static let pinchPollIntervalNanos: UInt64 = 16_000_000
}
