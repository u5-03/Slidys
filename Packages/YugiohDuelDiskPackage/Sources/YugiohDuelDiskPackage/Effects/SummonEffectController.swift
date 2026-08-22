//
//  SummonEffectController.swift
//  YugiohDuelDiskPackage
//
//  遊戯王風の召喚エフェクト。
//   ① グラウンドフラッシュ: 足元から光の粒が burst で上方向に噴き上がる
//   ② 上昇パーティクル: キラキラした光の粒が柱状に立ち上り、減速しながら消える
//   ③ PointLight: burst と同期した一瞬の周囲照らし
//
//  visionOS はポストプロセス(ブルーム)が使えないため、
//  加算ブレンド(additive)のパーティクルの重なりで擬似グローを作る。
//  キラキラ感は「4方向の光条を持つ星型スプライト(コード生成)+ 粒ごとのランダム回転
//  + 消え際の点収縮」で出す。丸いデフォルトスプライトのままだと白い点の飛散にしか見えない。
//  ParticleEmitterComponent は値型のため、burst() や birthRate 変更後は
//  components.set() で必ず書き戻す(忘れると何も起きない)。
//

#if os(visionOS)
import RealityKit
import UIKit

/// 召喚エフェクト一式をカプセル化し、`playSummon()` でタイムライン再生する。
/// シーケンスはコード主導(タイミングを全てここに集約する)。
///
/// タイムライン:
/// ```
/// t=0.00s ▶ burst 発火(グラウンドフラッシュ) + PointLight 点灯
/// t=0.10s ▶ 上昇パーティクル birthRate ON
/// t=1.50s ▶ 上昇パーティクル birthRate OFF(既存粒は寿命まで生存)
/// t=3.00s ▶ 演出完了(root を親から取り外す)
/// ```
@MainActor
public final class SummonEffectController {
    public let root: Entity
    private let groundBurst: Entity
    private let risingSparks: Entity
    private let verticalRays: Entity
    private let lightEntity: Entity

    private init(
        root: Entity,
        groundBurst: Entity,
        risingSparks: Entity,
        verticalRays: Entity,
        lightEntity: Entity
    ) {
        self.root = root
        self.groundBurst = groundBurst
        self.risingSparks = risingSparks
        self.verticalRays = verticalRays
        self.lightEntity = lightEntity
    }

    /// グリントテクスチャの TextureResource 生成が async のため、factory も async。
    public static func make() async -> SummonEffectController {
        let root = Entity()
        root.name = "SummonEffectRoot"

        let glint = await glintTexture()

        let groundBurst = makeGroundBurst(glint: glint)
        groundBurst.name = "SummonGroundBurst"
        root.addChild(groundBurst)

        let risingSparks = makeRisingSparks(glint: glint)
        risingSparks.name = "SummonRisingSparks"
        // 円筒ボリュームの中心を原点にすると柱が地面にめり込むため、半分だけ持ち上げる
        risingSparks.position = SIMD3<Float>(0, Params.risingColumnHeight / 2, 0)
        root.addChild(risingSparks)

        let verticalRays = makeVerticalRays()
        verticalRays.name = "SummonVerticalRays"
        root.addChild(verticalRays)

        let lightEntity = Entity()
        lightEntity.name = "SummonPointLight"
        lightEntity.position = SIMD3<Float>(0, Params.lightHeight, 0)
        root.addChild(lightEntity)

        return SummonEffectController(
            root: root,
            groundBurst: groundBurst,
            risingSparks: risingSparks,
            verticalRays: verticalRays,
            lightEntity: lightEntity
        )
    }

    /// 召喚演出を最後まで再生する。演出完了後に root を親から取り外す。
    /// 途中で `stop()` された場合も安全に終了する(remove 済み Entity への操作は no-op)。
    public func playSummon() async {
        // t=0.00: グラウンドフラッシュ + ライト点灯
        fireBurst()
        flashPointLight()
        try? await Task.sleep(for: .milliseconds(100))

        // t=0.10: 上昇きらめきフィールド + 縦の光筋
        setRisingBirthRate(Params.risingBirthRate)
        setRayBirthRate(Params.rayBirthRate)
        try? await Task.sleep(for: .milliseconds(1400))

        // t=1.50: 放出停止(残った粒は寿命まで生存させる)
        setRisingBirthRate(0)
        setRayBirthRate(0)
        try? await Task.sleep(for: .milliseconds(1500))

        // t=3.00: 演出完了
        stop()
    }

    /// エフェクトを即座に片付ける(スロット削除・再入場時のクリーンアップ用)。
    public func stop() {
        // 粒の残留を防ぐため、放出を止めてから取り外す
        setRisingBirthRate(0)
        setRayBirthRate(0)
        root.removeFromParent()
    }
}

// MARK: - パラメータ

private extension SummonEffectController {
    /// パーティクルのチューニング値。
    /// アリーナスロット(幅 0.464m)とモンスター(高さ約 0.4m)のスケールに合わせている。
    /// 粒数はフィルレートに直結するため、フレーム落ちが出たらここから削る。
    enum Params {
        // グラウンドフラッシュ(足元で一度きらめく)
        // 大量・大粒だと additive で白飛びするため、少なめ・小粒で「弾けて瞬く」印象にする。
        static let burstCount = 350
        static let burstCountVariation = 80
        static let burstSourceRadius: Float = 0.1
        static let burstSpeed: Float = 1.0
        static let burstLifeSpan: Double = 0.8
        /// 噴出円錐の広がり(ラジアン)。約80° = 底面の広い円錐
        static let burstSpreadingAngle: Float = 1.4
        static let burstSize: Float = 0.016
        static let burstSizeVariation: Float = 0.01

        // 上昇きらめきフィールド
        // 背の高い円筒ボリューム全体から粒を生み、ゆっくり漂わせて「その場で瞬く星の霧」を作る。
        static let risingBirthRate: Float = 900
        static let risingRadius: Float = 0.22
        /// 発生ボリュームの高さ。粒がこの柱の中に最初から散らばる = 縦に広がった星の霧
        static let risingColumnHeight: Float = 0.55
        static let risingSpeed: Float = 0.35          // ほぼ漂う程度。速いと「飛散」に見える
        static let risingSpeedVariation: Float = 0.25
        static let risingLifeSpan: Double = 0.9
        /// 寿命を大きくばらす → 粒が別々のタイミングで生まれ消える = チカチカ瞬く
        static let risingLifeSpanVariation: Double = 0.7
        static let risingSpreadingAngle: Float = 0.7
        static let risingSize: Float = 0.013
        static let risingSizeVariation: Float = 0.009

        // 縦の光筋(god ray)。速く真上に伸ばした細い粒を stretchFactor で線状に。
        static let rayBirthRate: Float = 90
        static let rayRadius: Float = 0.12
        static let raySpeed: Float = 1.6
        static let rayLifeSpan: Double = 0.7
        static let raySize: Float = 0.02
        static let rayStretchFactor: Float = 12

        // キラキラ(グリント)の見た目
        static let glintTextureDimension = 128
        /// 粒ごとの初期回転を全方位にばらす(光条の向きが揃うと人工的に見える)
        static let glintAngleVariation: Float = .pi * 2
        /// 回転はごく僅か。速く回すと「回転する破片」に見えて瞬き感が消える
        static let glintAngularSpeed: Float = 0.0
        static let glintAngularSpeedVariation: Float = 0.4

        // PointLight
        static let lightHeight: Float = 0.3
        static let lightIntensity: Float = 8_000
        static let lightAttenuationRadius: Float = 2.0
        static let lightFadeSteps = 6
        static let lightFadeStepMillis = 50
    }

    /// キラキラの色レンジ(白 ↔ 金)。additive で重なると白飛びして光って見える。
    static var sparkleWhite: UIColor { UIColor.white }
    static var sparkleGold: UIColor { UIColor(red: 1.0, green: 0.9, blue: 0.55, alpha: 1.0) }
    /// 消え際の色(薄い水色 → 透明)
    static var sparkleFadeCyan: UIColor { UIColor(red: 0.7, green: 0.95, blue: 1.0, alpha: 0.0) }
    static var sparkleFadeGreen: UIColor { UIColor(red: 0.55, green: 1.0, blue: 0.7, alpha: 0.0) }
}

// MARK: - グリント(星型)テクスチャ生成

private extension SummonEffectController {
    /// 生成済みテクスチャのキャッシュ(全召喚で共有)
    static var cachedGlintTexture: TextureResource?

    /// 「中心グロー + 縦横4方向の光条」のスプライトを返す。
    /// 生成に失敗した場合は nil(= デフォルトの丸スプライトにフォールバック)。
    static func glintTexture() async -> TextureResource? {
        if let cachedGlintTexture { return cachedGlintTexture }
        guard let image = makeGlintImage(dimension: Params.glintTextureDimension) else {
            return nil
        }
        let texture = try? await TextureResource(
            image: image,
            options: .init(semantic: .color)
        )
        cachedGlintTexture = texture
        return texture
    }

    /// CoreGraphics で 8-point sparkle(繊細な四芒星+短い斜め光条)を描く。
    /// 太いひし形だと「角ばった破片」に見えるため、光条は細く長く・先端へ鋭くフェードさせる。
    /// additive 合成前提なので「透明背景に白」で描けば黒縁は出ない。
    static func makeGlintImage(dimension: Int) -> CGImage? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(
            data: nil,
            width: dimension,
            height: dimension,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }

        let size = CGFloat(dimension)
        let center = CGPoint(x: size / 2, y: size / 2)

        guard let fadeGradient = CGGradient(
            colorsSpace: colorSpace,
            colors: [
                UIColor.white.cgColor,
                UIColor.white.withAlphaComponent(0.0).cgColor,
            ] as CFArray,
            locations: [0.0, 1.0]
        ) else { return nil }

        // 細い光条を1本描くヘルパー。中心から (dx,dy) 方向へ長さ length、根元幅 halfWidth のひし形。
        func drawRay(dx: CGFloat, dy: CGFloat, length: CGFloat, halfWidth: CGFloat) {
            let len = hypot(dx, dy)
            let ux = dx / len
            let uy = dy / len
            let tip = CGPoint(x: center.x + ux * length, y: center.y + uy * length)
            // 光条方向と直交する向きに根元の幅を持たせる
            let side = CGPoint(x: -uy * halfWidth, y: ux * halfWidth)

            let path = CGMutablePath()
            path.move(to: CGPoint(x: center.x + side.x, y: center.y + side.y))
            path.addLine(to: tip)
            path.addLine(to: CGPoint(x: center.x - side.x, y: center.y - side.y))
            path.closeSubpath()

            context.saveGState()
            context.addPath(path)
            context.clip()
            context.drawRadialGradient(
                fadeGradient,
                startCenter: center,
                startRadius: 0,
                endCenter: center,
                endRadius: length,
                options: []
            )
            context.restoreGState()
        }

        // 主光条: 縦横4方向に長く細く
        let mainLength = size * 0.48
        let mainHalfWidth = size * 0.012
        for (dx, dy) in [(1.0, 0.0), (-1.0, 0.0), (0.0, 1.0), (0.0, -1.0)] {
            drawRay(dx: dx, dy: dy, length: mainLength, halfWidth: mainHalfWidth)
        }
        // 斜め光条: 短く細く(八芒星のきらめきを足す)
        let diagLength = size * 0.26
        let diagHalfWidth = size * 0.007
        for (dx, dy) in [(1.0, 1.0), (1.0, -1.0), (-1.0, 1.0), (-1.0, -1.0)] {
            drawRay(dx: dx, dy: dy, length: diagLength, halfWidth: diagHalfWidth)
        }

        // 中心グロー: 白 → 透明の放射グラデーション(小さく引き締める)
        context.drawRadialGradient(
            fadeGradient,
            startCenter: center,
            startRadius: 0,
            endCenter: center,
            endRadius: size * 0.09,
            options: []
        )

        return context.makeImage()
    }
}

// MARK: - Entity 生成

private extension SummonEffectController {
    /// 星型スプライト + ランダム回転 + 消え際の点収縮、のキラキラ共通設定。
    static func applyGlintLook(to emitter: inout ParticleEmitterComponent, glint: TextureResource?) {
        if let glint {
            emitter.mainEmitter.image = glint
        }
        emitter.mainEmitter.blendMode = .additive // 重なるほど白飛び = 擬似ブルーム
        emitter.mainEmitter.billboardMode = .billboard
        emitter.mainEmitter.angleVariation = Params.glintAngleVariation
        emitter.mainEmitter.angularSpeed = Params.glintAngularSpeed
        emitter.mainEmitter.angularSpeedVariation = Params.glintAngularSpeedVariation
        // 寿命の最後は点に収縮して消える(スッと消える「瞬き」の余韻)
        emitter.mainEmitter.sizeMultiplierAtEndOfLifespan = 0.0
        emitter.mainEmitter.opacityCurve = .quickFadeInOut
    }

    /// ① グラウンドフラッシュ。連続放出(birthRate)ではなく burst() による瞬間放出を使う。
    /// 足元の小さな発生源から「底面の広い円錐」状に噴き上げる。
    static func makeGroundBurst(glint: TextureResource?) -> Entity {
        let entity = Entity()
        // sparks プリセットを起点に、単発 burst の上方向噴出に改造する
        var emitter = ParticleEmitterComponent.Presets.sparks

        // 放出域: 足元の小さな球。ここから上向きに弾ける
        emitter.emitterShape = .sphere
        emitter.emitterShapeSize = SIMD3<Float>(repeating: Params.burstSourceRadius)
        emitter.birthLocation = .volume
        emitter.emissionDirection = SIMD3<Float>(0, 1, 0)
        emitter.birthDirection = .local

        // 単発 burst 用設定: 常時放出はゼロ
        emitter.mainEmitter.birthRate = 0
        emitter.burstCount = Params.burstCount
        emitter.burstCountVariation = Params.burstCountVariation

        // 上向き + 広い円錐状の散らし。減速しながら頂点で消える
        emitter.speed = Params.burstSpeed
        emitter.speedVariation = 0.5
        emitter.mainEmitter.spreadingAngle = Params.burstSpreadingAngle
        emitter.mainEmitter.acceleration = SIMD3<Float>(0, -0.8, 0)
        emitter.mainEmitter.dampingFactor = 3.0
        emitter.mainEmitter.lifeSpan = Params.burstLifeSpan
        emitter.mainEmitter.lifeSpanVariation = 0.4

        // 見た目: 白〜金のランダムカラー → 薄緑に変化しながら消える
        emitter.mainEmitter.size = Params.burstSize
        emitter.mainEmitter.sizeVariation = Params.burstSizeVariation
        emitter.mainEmitter.color = .evolving(
            start: .random(a: sparkleWhite, b: sparkleGold),
            end: .single(sparkleFadeGreen)
        )
        applyGlintLook(to: &emitter, glint: glint)

        entity.components.set(emitter)
        return entity
    }

    /// ② 上昇するきらめきフィールド。birthRate の書き換えで ON/OFF する。
    /// 背の高い円筒ボリューム全体から粒を生み、ゆっくり漂わせて「その場で瞬く星の霧」にする。
    static func makeRisingSparks(glint: TextureResource?) -> Entity {
        let entity = Entity()
        var emitter = ParticleEmitterComponent.Presets.magic

        // 背の高い円筒 = 粒が縦方向に最初から散らばる(下からドバッと吹き上げない)
        emitter.emitterShape = .cylinder
        emitter.emitterShapeSize = SIMD3<Float>(
            Params.risingRadius,
            Params.risingColumnHeight,
            Params.risingRadius
        )
        emitter.birthLocation = .volume
        emitter.emissionDirection = SIMD3<Float>(0, 1, 0)
        emitter.birthDirection = .local

        emitter.mainEmitter.birthRate = 0        // 初期 OFF。playSummon() で ON にする
        emitter.speed = Params.risingSpeed       // ほぼ漂う程度
        emitter.speedVariation = Params.risingSpeedVariation
        emitter.mainEmitter.lifeSpan = Params.risingLifeSpan
        // 寿命を大きくばらす → 粒が別々のタイミングで生まれて消える = チカチカ瞬く
        emitter.mainEmitter.lifeSpanVariation = Params.risingLifeSpanVariation
        emitter.mainEmitter.size = Params.risingSize
        emitter.mainEmitter.sizeVariation = Params.risingSizeVariation
        emitter.mainEmitter.spreadingAngle = Params.risingSpreadingAngle
        emitter.mainEmitter.acceleration = SIMD3<Float>(0, 0.1, 0) // ふわっと上に漂わせる程度
        emitter.mainEmitter.color = .evolving(
            start: .random(a: sparkleWhite, b: sparkleGold),
            end: .single(sparkleFadeCyan)
        )
        applyGlintLook(to: &emitter, glint: glint)

        entity.components.set(emitter)
        return entity
    }

    /// ③ 縦の光筋(god ray)。真上に速く伸ばした細い粒を stretchFactor で線状に見せる。
    /// 参考映像の「縦に走る光の筋」を再現する下支えレイヤー。
    static func makeVerticalRays() -> Entity {
        let entity = Entity()
        var emitter = ParticleEmitterComponent.Presets.magic

        emitter.emitterShape = .cylinder
        emitter.emitterShapeSize = SIMD3<Float>(Params.rayRadius, 0.02, Params.rayRadius)
        emitter.birthLocation = .volume
        emitter.emissionDirection = SIMD3<Float>(0, 1, 0)
        emitter.birthDirection = .local

        emitter.mainEmitter.birthRate = 0        // 初期 OFF。playSummon() で ON にする
        emitter.speed = Params.raySpeed
        emitter.speedVariation = 0.4
        emitter.mainEmitter.lifeSpan = Params.rayLifeSpan
        emitter.mainEmitter.lifeSpanVariation = 0.3
        emitter.mainEmitter.size = Params.raySize
        emitter.mainEmitter.sizeVariation = 0.01
        emitter.mainEmitter.spreadingAngle = 0.05   // ほぼ真上
        // 速度方向(=上)に大きく引き伸ばして「線」にする
        emitter.mainEmitter.stretchFactor = Params.rayStretchFactor
        emitter.mainEmitter.blendMode = .additive
        emitter.mainEmitter.billboardMode = .billboard
        emitter.mainEmitter.color = .evolving(
            start: .single(sparkleWhite),
            end: .single(sparkleFadeCyan)
        )
        emitter.mainEmitter.opacityCurve = .quickFadeInOut

        entity.components.set(emitter)
        return entity
    }
}

// MARK: - 再生制御

private extension SummonEffectController {
    func fireBurst() {
        // 値型コンポーネントのため取り出し → burst() → 再 set が必須
        guard var emitter = groundBurst.components[ParticleEmitterComponent.self] else { return }
        emitter.burst()
        groundBurst.components.set(emitter)
    }

    func setRisingBirthRate(_ rate: Float) {
        guard var emitter = risingSparks.components[ParticleEmitterComponent.self] else { return }
        emitter.mainEmitter.birthRate = rate
        risingSparks.components.set(emitter)
    }

    func setRayBirthRate(_ rate: Float) {
        guard var emitter = verticalRays.components[ParticleEmitterComponent.self] else { return }
        emitter.mainEmitter.birthRate = rate
        verticalRays.components.set(emitter)
    }

    /// PointLight を点灯し、段階的にフェードアウトして外す。
    /// mixed immersion では現実側は照らせないが、モンスターへの回り込みに効く。
    func flashPointLight() {
        lightEntity.components.set(PointLightComponent(
            color: .white,
            intensity: Params.lightIntensity,
            attenuationRadius: Params.lightAttenuationRadius
        ))
        Task { @MainActor [lightEntity] in
            for step in 1...Params.lightFadeSteps {
                try? await Task.sleep(for: .milliseconds(Params.lightFadeStepMillis))
                let fraction = 1 - Float(step) / Float(Params.lightFadeSteps)
                lightEntity.components.set(PointLightComponent(
                    color: .white,
                    intensity: Params.lightIntensity * fraction,
                    attenuationRadius: Params.lightAttenuationRadius
                ))
            }
            lightEntity.components.remove(PointLightComponent.self)
        }
    }
}
#endif
