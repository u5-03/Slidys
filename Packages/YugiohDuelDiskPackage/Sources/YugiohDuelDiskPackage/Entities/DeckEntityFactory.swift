//
//  DeckEntityFactory.swift
//  YugiohDuelDiskPackage
//
//  ディスク上に置くデッキ(直方体)を作るファクトリ。
//

import Foundation
import RealityKit
#if canImport(UIKit)
import UIKit
#endif

public enum DeckEntityFactory {
    /// 40 枚分の厚みを持ったデッキ Entity を作る。
    /// - 検証モードでは枚数は減らさないが、見た目だけ「だんだん薄くなる」演出に拡張する余地を残す。
    public static func make(remaining: Int = DuelDiskMetrics.deckCardCount) -> ModelEntity {
        let height = Float(max(remaining, 1)) * DuelDiskMetrics.cardThickness
        let mesh = MeshResource.generateBox(
            width: DuelDiskMetrics.cardWidth,
            height: height,
            depth: DuelDiskMetrics.cardDepth
        )
        var material = SimpleMaterial()
#if canImport(UIKit)
        // カード裏面の茶色。チャネルの白地・影の中でも視認できる明るさにする
        material.color = .init(tint: UIColor(red: 0.72, green: 0.55, blue: 0.36, alpha: 1.0))
#endif
        material.metallic = 0.1
        material.roughness = 0.6
        let entity = ModelEntity(mesh: mesh, materials: [material])
        entity.name = "DuelDeck" // デバッグ用。判定には DeckMarkerComponent を使う。
#if os(visionOS)
        entity.components.set(DeckMarkerComponent())
#endif
        return entity
    }
}
