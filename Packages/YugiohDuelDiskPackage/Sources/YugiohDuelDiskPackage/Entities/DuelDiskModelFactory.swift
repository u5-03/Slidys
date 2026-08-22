//
//  DuelDiskModelFactory.swift
//  YugiohDuelDiskPackage
//
//  Blender 製デュエルディスク (YugiohDuelDisk.usdz) の読み込みとタップ対象の設定。
//  モデルの原点 = `WristAnchor` ノード = 円盤裏面の中央。
//  そのため手首アンカーへはモデルのルートをそのまま addChild すれば固定できる。
//
//  ノード契約 (Notion チケット「デュエルディスクUSDZ: visionOS位置取得・タップ判定の実装情報」):
//  - WristAnchor / DeckSlot / GraveyardSlot / CardSlot_1...5 / LifeDisplay : Empty (Xform)
//  - Button_1...5 / SpellSlot_1...5 / Zone_1...5_Field : タップ対象メッシュ
//

import Foundation
import RealityKit
#if canImport(UIKit)
import UIKit
#endif

public enum DuelDiskModelFactory {
    public static let modelName = "YugiohDuelDisk"
    public static let buttonNames = (1...5).map { "Button_\($0)" }
    public static let spellSlotNames = (1...5).map { "SpellSlot_\($0)" }
    public static let graveyardSlotName = "GraveyardSlot"
    public static let deckSlotName = "DeckSlot"
    public static let lifeDisplayName = "LifeDisplay"
    public static let zoneFieldNames = (1...5).map { "Zone_\($0)_Field" }

    /// ディスクモデルを読み込む。
    /// アセットは YugiohDuelDisk.rkassets (RCP コンテンツパッケージ) に格納されており、
    /// Xcode ビルドでは realitytool コンパイル済みシーン、CLI ビルドでは raw USDZ が
    /// 同名 "YugiohDuelDisk" で解決される。
    @MainActor
    public static func load() async throws -> Entity {
        let model = try await Entity(named: modelName, in: Bundle.module)
        model.name = "DuelDiskModel"
        brightenMaterials(on: model)
        return model
    }

    /// ディスクが暗く見えるのを緩和するため、モデル内マテリアルに軽い自発光を足して底上げする。
    /// 環境光に依存せず一定量明るくなる。強すぎると白飛びするので控えめ (emissiveIntensity) にする。
    @MainActor
    public static func brightenMaterials(on entity: Entity, emissiveIntensity: Float = 0.35) {
#if canImport(UIKit)
        if var model = entity.components[ModelComponent.self] {
            model.materials = model.materials.map { material in
                if var pbr = material as? PhysicallyBasedMaterial {
                    // ベースカラーを自発光として薄く足す(色味を保ったまま明るくする)
                    let tint = pbr.baseColor.tint
                    pbr.emissiveColor = .init(color: tint)
                    pbr.emissiveIntensity = emissiveIntensity
                    return pbr
                }
                return material
            }
            entity.components.set(model)
        }
        for child in entity.children {
            brightenMaterials(on: child, emissiveIntensity: emissiveIntensity)
        }
#endif
    }

    /// Button / SpellSlot / Graveyard にタップ判定 (Collision + InputTarget) を付与する。
    @MainActor
    public static func configureTapTargets(on model: Entity) {
#if os(visionOS)
        for name in buttonNames + spellSlotNames {
            guard let entity = model.findEntity(named: name) else {
                continue
            }
            let bounds = entity.visualBounds(relativeTo: entity)
            let extents = bounds.extents
            // スリット等は薄いので、押しやすいように最低サイズを確保する
            let size = SIMD3<Float>(
                max(extents.x, 0.05),
                max(extents.y, 0.012),
                max(extents.z, 0.02)
            )
            // メッシュ原点と見た目の中心はズレていることがあるため、判定箱を bounds 中心へ寄せる
            entity.components.set(CollisionComponent(
                shapes: [.generateBox(size: size).offsetBy(translation: bounds.center)],
                isStatic: true,
                filter: .default
            ))
            entity.components.set(InputTargetComponent())
            // 魔法・トラップ挿入口(SpellSlot)は視線で分かるよう強めのハイライトにする
            if name.hasPrefix("SpellSlot_") {
                entity.components.set(DuelHoverStyle.spellSlot)
            } else {
                entity.components.set(HoverEffectComponent())
            }
        }
        // 召喚ゾーン面: ゾーン全体をタップ可能にする (DiskSlot plane の補完ではなく主判定)
        for name in zoneFieldNames {
            guard let entity = model.findEntity(named: name) else { continue }
            let bounds = entity.visualBounds(relativeTo: entity)
            let extents = bounds.extents
            let size = SIMD3<Float>(max(extents.x, 0.05), max(extents.y, 0.01), max(extents.z, 0.08))
            entity.components.set(CollisionComponent(
                shapes: [.generateBox(size: size).offsetBy(translation: bounds.center)],
                isStatic: true,
                filter: .default
            ))
            entity.components.set(InputTargetComponent())
            // 召喚できる状態が分かるよう、召喚スロットと同じ強いハイライトにする
            entity.components.set(DuelHoverStyle.summonSlot)
        }
        // 墓地の口は Empty (形状なし) のため判定箱を直接指定する
        if let grave = model.findEntity(named: graveyardSlotName) {
            grave.components.set(CollisionComponent(
                shapes: [.generateBox(size: SIMD3<Float>(0.062, 0.010, 0.024))],
                isStatic: true,
                filter: .default
            ))
            grave.components.set(InputTargetComponent())
            grave.components.set(HoverEffectComponent())
        }
#endif
    }

    /// タップされた Entity (またはその祖先) からディスク部品名を解決する。
    public static func resolveTapPartName(from entity: Entity?) -> String? {
        var current = entity
        var depth = 0
        while let e = current, depth < 6 {
            let name = e.name
            if name == graveyardSlotName {
                return name
            }
            if name.hasPrefix("Button_") || name.hasPrefix("SpellSlot_") {
                // メッシュ子は "Button_3_005" のような名前になるため、
                // "Button_3" の正規名に丸めて返す
                let parts = name.split(separator: "_")
                if parts.count >= 2 {
                    return "\(parts[0])_\(parts[1])"
                }
                return name
            }
            current = e.parent
            depth += 1
        }
        return nil
    }

    /// タップされた Entity (またはその祖先) からゾーン番号 (0-based slot index) を解決する。
    /// "Zone_3_Field" やそのメッシュ子 → 2 を返す。
    public static func resolveZoneFieldIndex(from entity: Entity?) -> Int? {
        var current = entity
        var depth = 0
        while let e = current, depth < 6 {
            let name = e.name
            if name.hasPrefix("Zone_") {
                let parts = name.split(separator: "_")
                if parts.count >= 2, let number = Int(parts[1]), (1...5).contains(number) {
                    return number - 1
                }
            }
            current = e.parent
            depth += 1
        }
        return nil
    }
}
