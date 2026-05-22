//
//  CardEntityFactory.swift
//  YugiohDuelDiskPackage
//
//  カード本体(単色の薄い直方体)を生成するファクトリ。
//

import Foundation
import RealityKit
#if canImport(UIKit)
import UIKit
#endif

public enum CardEntityFactory {
    /// すべてのカードに使う共通色(裏面風の濃紺)。
    /// Phase B1 確定: 全カード同色。
#if canImport(UIKit)
    public static let cardColor = UIColor(red: 0.15, green: 0.18, blue: 0.35, alpha: 1.0)
#endif

    /// カード Entity を作る。
    /// - hover 表現用に `InputTargetComponent` + `HoverEffectComponent` を常時付ける。
    /// - `CardIdentityComponent` で card.id を保持する(衝突判定で識別する用)。
    /// - `CollisionComponent` (mode/filter) の付与は呼び出し側の責務(扇 / 右手 / ディスク / アリーナで条件が違うため)。
    public static func make(model: CardModel) -> ModelEntity {
        let mesh = MeshResource.generateBox(
            width: DuelDiskMetrics.cardWidth,
            height: DuelDiskMetrics.cardThickness,
            depth: DuelDiskMetrics.cardDepth
        )
        var material = SimpleMaterial()
#if canImport(UIKit)
        material.color = .init(tint: Self.cardColor)
#endif
        material.metallic = 0.0
        material.roughness = 0.4
        let entity = ModelEntity(mesh: mesh, materials: [material])
        entity.name = "Card_\(model.id.uuidString)" // デバッグ用。ID 判定には Component を使う。

        // visionOS 標準の hover ハイライト
        entity.components.set(InputTargetComponent())
        entity.components.set(HoverEffectComponent())

#if os(visionOS)
        // Card 識別用の Component
        entity.components.set(CardIdentityComponent(id: model.id))
#endif
        return entity
    }
}
