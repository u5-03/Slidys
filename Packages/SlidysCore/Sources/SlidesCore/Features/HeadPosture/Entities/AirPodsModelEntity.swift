//
//  AirPodsModelEntity.swift
//  HeadPosturePackage
//
//  Created by Yugo Sugiyama on 2025/12/14.
//

import RealityKit
import CoreGraphics
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif
import simd

@MainActor
public enum AirPodsModelEntity {
    /// 簡易AirPodモデル: 球体 + ステム（カプセル風にシリンダー＋球で構成）
    /// scale: モデル全体のスケール（デフォルト1.0）
    public static func createSimpleAirPod(isLeft: Bool, scale: Float = 1.0) -> Entity {
        let earbudEntity = Entity()

        // 本体（球）
        var bodyMaterial = SimpleMaterial()
        bodyMaterial.color = .init(tint: .white)
        bodyMaterial.roughness = 0.3
        bodyMaterial.metallic = 0.2

        let bodyMesh = MeshResource.generateSphere(radius: 0.06 * scale)
        let body = ModelEntity(mesh: bodyMesh, materials: [bodyMaterial])
        earbudEntity.addChild(body)

        // ステム（シリンダー）
        var stemMaterial = SimpleMaterial()
        stemMaterial.color = .init(tint: .white)
        stemMaterial.roughness = 0.3
        stemMaterial.metallic = 0.2

        let stemMesh = MeshResource.generateCylinder(height: 0.18 * scale, radius: 0.022 * scale)
        let stem = ModelEntity(mesh: stemMesh, materials: [stemMaterial])
        stem.position = SIMD3<Float>(0, -0.135 * scale, 0)
        earbudEntity.addChild(stem)

        // ステム先端（球）
        let stemTipMesh = MeshResource.generateSphere(radius: 0.022 * scale)
        let stemTip = ModelEntity(mesh: stemTipMesh, materials: [stemMaterial])
        stemTip.position = SIMD3<Float>(0, -0.225 * scale, 0)
        earbudEntity.addChild(stemTip)

        return earbudEntity
    }

    /// 正面から見た頭のモデル（耳の位置にAirPodsを配置）
    /// 左右のAirPodsエンティティを返す（ジャイロで個別に動かすため）
    /// scale: モデル全体のスケール（デフォルト1.0）
    public static func createFrontViewHead(scale: Float = 1.0) -> (head: Entity, leftAirPod: Entity, rightAirPod: Entity) {
        let rootEntity = Entity()

        // 頭 - 透明度を下げる
        var headMaterial = SimpleMaterial()
        headMaterial.color = .init(tint: .init(red: 0.95, green: 0.82, blue: 0.72, alpha: 0.3))
        headMaterial.roughness = 0.9
        headMaterial.metallic = 0.0

        let headMesh = MeshResource.generateSphere(radius: 0.5 * scale)
        let head = ModelEntity(mesh: headMesh, materials: [headMaterial])
        // 頭を先にレンダリング（order: 0）し、顔パーツを後にレンダリングすることで
        // 裏面からも透けて見えるようにする
        let sortGroup = ModelSortGroup(depthPass: .postPass)
        head.components.set(ModelSortGroupComponent(group: sortGroup, order: 0))
        rootEntity.addChild(head)

        // 顔のパーツ（SF Symbol - 両面表示で裏面からも透けて見える）
        addFaceFeature(
            to: rootEntity, symbolName: "eyes.inverse",
            width: 0.4 * scale, height: 0.18 * scale,
            yOffset: 0.22 * scale, zOffset: 0.501 * scale,
            sortGroup: sortGroup
        )
        addFaceFeature(
            to: rootEntity, symbolName: "nose.fill",
            width: 0.12 * scale, height: 0.14 * scale,
            yOffset: 0.08 * scale, zOffset: 0.501 * scale,
            sortGroup: sortGroup
        )
        addFaceFeature(
            to: rootEntity, symbolName: "mouth.fill",
            width: 0.18 * scale, height: 0.1 * scale,
            yOffset: -0.03 * scale, zOffset: 0.501 * scale,
            sortGroup: sortGroup
        )

        // 左耳（正面から見て左側）
        var earMaterial = SimpleMaterial()
        earMaterial.color = .init(tint: .init(red: 0.92, green: 0.78, blue: 0.68, alpha: 0.4))
        earMaterial.roughness = 0.9

        let earMesh = MeshResource.generateSphere(radius: 0.12 * scale)

        let leftEar = ModelEntity(mesh: earMesh, materials: [earMaterial])
        leftEar.position = SIMD3<Float>(-0.5 * scale, 0, 0)
        leftEar.scale = SIMD3<Float>(0.4, 1.0, 0.8)
        rootEntity.addChild(leftEar)

        let rightEar = ModelEntity(mesh: earMesh, materials: [earMaterial])
        rightEar.position = SIMD3<Float>(0.5 * scale, 0, 0)
        rightEar.scale = SIMD3<Float>(0.4, 1.0, 0.8)
        rootEntity.addChild(rightEar)

        // 左AirPod（正面から見て左側の耳に装着）
        let leftAirPod = createSimpleAirPod(isLeft: true, scale: scale * 1.5)
        leftAirPod.position = SIMD3<Float>(-0.6 * scale, 0, 0)
        // 耳に装着した向き（ステムが下向き、少し外側に傾く、前方に傾ける - マイクが口元に向く）
        let leftTiltZ = simd_quatf(angle: -.pi / 8, axis: SIMD3<Float>(0, 0, 1))  // 外側に傾く
        let leftTiltX = simd_quatf(angle: .pi / 6, axis: SIMD3<Float>(1, 0, 0))  // 前方に30度傾ける
        leftAirPod.transform.rotation = leftTiltX * leftTiltZ
        rootEntity.addChild(leftAirPod)

        // 右AirPod（正面から見て右側の耳に装着）
        let rightAirPod = createSimpleAirPod(isLeft: false, scale: scale * 1.5)
        rightAirPod.position = SIMD3<Float>(0.6 * scale, 0, 0)
        // 耳に装着した向き（ステムが下向き、少し外側に傾く、前方に傾ける - マイクが口元に向く）
        let rightTiltZ = simd_quatf(angle: .pi / 8, axis: SIMD3<Float>(0, 0, 1))  // 外側に傾く
        let rightTiltX = simd_quatf(angle: .pi / 6, axis: SIMD3<Float>(1, 0, 0))  // 前方に30度傾ける
        rightAirPod.transform.rotation = rightTiltX * rightTiltZ
        rootEntity.addChild(rightAirPod)

        return (rootEntity, leftAirPod, rightAirPod)
    }

    /// 後ろから見た頭のモデル（互換性のため残す）
    @available(*, deprecated, renamed: "createFrontViewHead")
    public static func createBackViewHead(scale: Float = 1.0) -> (head: Entity, leftAirPod: Entity, rightAirPod: Entity) {
        return createFrontViewHead(scale: scale)
    }

    /// SF Symbolの顔パーツを両面描画で前面に配置する
    /// 背面は左右反転テクスチャで裏から透けて見た時に自然に見える
    private static func addFaceFeature(
        to parent: Entity,
        symbolName: String,
        width: Float,
        height: Float,
        yOffset: Float,
        zOffset: Float,
        sortGroup: ModelSortGroup
    ) {
        guard let frontTexture = createTextureFromSFSymbol(name: symbolName, pointSize: 200),
              let backTexture = createTextureFromSFSymbol(name: symbolName, pointSize: 200, mirrored: true, color: .gray)
        else { return }

        let plane = MeshResource.generatePlane(width: width, height: height)

        // 前面（-Z方向を向く）- Y軸180度回転
        var frontMaterial = UnlitMaterial()
        frontMaterial.color = .init(tint: .white, texture: .init(frontTexture))
        frontMaterial.blending = .transparent(opacity: 1.0)

        let frontEntity = ModelEntity(mesh: plane, materials: [frontMaterial])
        frontEntity.position = SIMD3<Float>(0, yOffset, -zOffset)
        frontEntity.transform.rotation = simd_quatf(angle: .pi, axis: SIMD3<Float>(0, 1, 0))
        frontEntity.components.set(ModelSortGroupComponent(group: sortGroup, order: 1))
        parent.addChild(frontEntity)

        // 背面（+Z方向を向く）- 左右反転テクスチャ、回転なし（法線+Zのまま）
        // 背面は遠近法で小さく見えるため、1.5倍のサイズ・間隔で描画
        let backScale: Float = 1.5
        let backPlane = MeshResource.generatePlane(width: width * backScale, height: height * backScale)
        var backMaterial = UnlitMaterial()
        backMaterial.color = .init(tint: .white, texture: .init(backTexture))
        backMaterial.blending = .transparent(opacity: 1.0)

        let backEntity = ModelEntity(mesh: backPlane, materials: [backMaterial])
        backEntity.position = SIMD3<Float>(0, yOffset * backScale, -zOffset)
        backEntity.components.set(ModelSortGroupComponent(group: sortGroup, order: 1))
        parent.addChild(backEntity)
    }

    /// SF Symbolを`TextureResource`に変換する
    private static func createTextureFromSFSymbol(
        name: String,
        pointSize: CGFloat,
        mirrored: Bool = false,
        color: PlatformColor = .black
    ) -> TextureResource? {
        #if canImport(UIKit)
        let config = UIImage.SymbolConfiguration(pointSize: pointSize, weight: .regular)
        guard let symbolImage = UIImage(systemName: name, withConfiguration: config)?
            .withTintColor(color, renderingMode: .alwaysOriginal) else { return nil }
        let renderer = UIGraphicsImageRenderer(size: symbolImage.size)
        let rendered = renderer.image { _ in
            symbolImage.draw(in: CGRect(origin: .zero, size: symbolImage.size))
        }
        guard let baseCGImage = rendered.cgImage else { return nil }
        #elseif canImport(AppKit)
        guard let symbolImage = NSImage(systemSymbolName: name, accessibilityDescription: nil) else { return nil }
        let config = NSImage.SymbolConfiguration(pointSize: pointSize, weight: .regular)
        let configured = symbolImage.withSymbolConfiguration(config) ?? symbolImage
        let tinted = NSImage(size: configured.size, flipped: false) { rect in
            configured.draw(in: rect)
            color.set()
            rect.fill(using: .sourceAtop)
            return true
        }
        guard let baseCGImage = tinted.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
        #endif
        let cgImage: CGImage
        if mirrored, let flipped = mirrorCGImageHorizontally(baseCGImage) {
            cgImage = flipped
        } else {
            cgImage = baseCGImage
        }
        return try? TextureResource(image: cgImage, options: .init(semantic: .color))
    }

    /// CGImageを水平方向に反転する
    private static func mirrorCGImageHorizontally(_ image: CGImage) -> CGImage? {
        let width = image.width
        let height = image.height
        guard let colorSpace = image.colorSpace,
              let context = CGContext(
                  data: nil,
                  width: width,
                  height: height,
                  bitsPerComponent: image.bitsPerComponent,
                  bytesPerRow: 0,
                  space: colorSpace,
                  bitmapInfo: image.bitmapInfo.rawValue
              ) else { return nil }
        context.translateBy(x: CGFloat(width), y: 0)
        context.scaleBy(x: -1, y: 1)
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        return context.makeImage()
    }
}
