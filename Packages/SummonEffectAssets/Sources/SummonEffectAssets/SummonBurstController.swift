//
//  SummonBurstController.swift
//  SummonEffectAssets
//
//  召喚バースト(放射線 + 手裏剣スパークル + 中央発光)の共通コントローラ。
//  RCP(Scene.usda)のパーティクルを読み込み、召喚断面(平面)から
//  「上半分だけのドーム」として表示する。緋天竜(iOS)/デュエルディスク(visionOS)で共用する。
//

#if canImport(RealityKit)
import Foundation
import RealityKit

@MainActor
public final class SummonBurstController {
    /// 召喚断面に配置するルート。この原点 = 球の中心 = 召喚断面。
    /// 下半分はオクルーダーで隠れるため、平面に置くと「断面から出る半球ドーム」になる。
    public let root: Entity
    private let effect: Entity
    private var stopTask: Task<Void, Never>?

    private init(root: Entity, effect: Entity) {
        self.root = root
        self.effect = effect
    }

    /// エフェクトを読み込んで生成する。
    /// - Parameters:
    ///   - scale: バースト全体の拡大率(素材は約1m基準)。配置先のスケールに合わせて調整する。
    ///   - clipsLowerHalf: true のとき、原点より下(y<0)をオクルーダーで隠して上半分ドームにする。
    public static func make(scale: Float, clipsLowerHalf: Bool = true) async -> SummonBurstController? {
        guard let effect = try? await Entity(named: "Scene", in: Bundle.module) else {
            return nil
        }
        effect.name = "SummonBurstEffect"
        effect.scale = SIMD3<Float>(repeating: scale)

        let root = Entity()
        root.name = "SummonBurst"
        root.addChild(effect)

        if clipsLowerHalf {
            // 下半分を隠すオクルーダー: 上面が root 原点(召喚断面)に来る大きな箱。
            // 球体・放射線の「原点より下」が隠れ、断面から出る半球ドームに見える。
            let side = max(scale, 0.001) * 6
            let occluder = ModelEntity(
                mesh: .generateBox(size: SIMD3<Float>(side, side, side)),
                materials: [OcclusionMaterial()]
            )
            occluder.name = "SummonBurstOccluder"
            occluder.position = SIMD3<Float>(0, -side / 2 - 0.001, 0) // 上面 ≒ y=0
            root.addChild(occluder)
        }

        let controller = SummonBurstController(root: root, effect: effect)
        controller.setEmitting(false) // 生成直後は止めておき、fire() で発火する
        return controller
    }

    /// 召喚バーストを発火する(発生ON → 一定時間後に発生OFF。残った粒は寿命でフェード)。
    /// Entity は残すため、再度 `fire()` すれば再発火できる。
    public func fire(emitDuration: TimeInterval = 1.2) {
        stopTask?.cancel()
        setEmitting(true)
        stopTask = Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(emitDuration * 1_000_000_000))
            self?.setEmitting(false)
        }
    }

    /// 完全停止 + ルートを親から取り外す(スロット削除・退室時のクリーンアップ用)。
    public func stop() {
        stopTask?.cancel()
        stopTask = nil
        setEmitting(false)
        root.removeFromParent()
    }

    /// 配下すべての ParticleEmitterComponent の発生 ON/OFF を切り替える。
    public func setEmitting(_ isEmitting: Bool) {
        Self.forEachEmitter(on: effect) { $0.isEmitting = isEmitting }
    }

    // NOTE: ParticleEmitterComponent.restart() は描画中のエミッタに対して呼ぶと
    // VFX内部(bucketVFXMeshPart)でEXC_BAD_ACCESSを起こすため使用しない。
    // 粒は短命なので isEmitting の ON/OFF だけで「最初から」に見える。

    private static func forEachEmitter(
        on entity: Entity, _ update: (inout ParticleEmitterComponent) -> Void
    ) {
        if var emitter = entity.components[ParticleEmitterComponent.self] {
            update(&emitter)
            entity.components.set(emitter)
        }
        for child in entity.children {
            forEachEmitter(on: child, update)
        }
    }
}
#endif
