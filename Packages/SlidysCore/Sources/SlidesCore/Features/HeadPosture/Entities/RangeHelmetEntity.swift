//
//  RangeHelmetEntity.swift
//  HeadPosturePackage
//
//  Created by Yugo Sugiyama on 2025/12/14.
//

import RealityKit
#if canImport(UIKit)
import UIKit
typealias PlatformColor = UIColor
#elseif canImport(AppKit)
import AppKit
typealias PlatformColor = NSColor
#endif
import simd

/// 有効範囲を示すアークインジケーターを生成
@MainActor
enum RangeHelmetEntity {

    /// 閾値に基づいて有効範囲のアークインジケーターを生成
    static func createHelmet(
        threshold: PostureThreshold,
        radius: Float = 0.7,
        scale: Float = 1.5
    ) -> Entity {
        let entity = Entity()
        entity.scale = SIMD3<Float>(repeating: scale)

        // 前後の傾き（Roll）のアーク - 青（半透明）
        addSmoothArc(
            to: entity,
            startAngle: Float(threshold.rollMin),
            endAngle: Float(threshold.rollMax),
            axis: .forward,
            color: .init(red: 0.2, green: 0.5, blue: 1.0, alpha: 0.5),
            radius: radius
        )

        // 左右を向く（Yaw）のアーク - 緑（半透明）
        addSmoothArc(
            to: entity,
            startAngle: Float(threshold.yawMin),
            endAngle: Float(threshold.yawMax),
            axis: .vertical,
            color: .init(red: 0.2, green: 0.9, blue: 0.2, alpha: 0.5),
            radius: radius
        )

        // 左右の傾き（Pitch）のアーク - 赤（半透明）
        addSmoothArc(
            to: entity,
            startAngle: Float(threshold.pitchMin),
            endAngle: Float(threshold.pitchMax),
            axis: .horizontal,
            color: .init(red: 1.0, green: 0.3, blue: 0.3, alpha: 0.5),
            radius: radius
        )

        return entity
    }

    private enum RotationAxis {
        case forward    // 前後（X軸周り）- うなずき
        case vertical   // 上下（Y軸周り）- 左右を向く
        case horizontal // 左右（Z軸周り）- 首かしげ
    }

    /// 滑らかなチューブ状のアークを追加（カスタムメッシュ版）
    private static func addSmoothArc(
        to entity: Entity,
        startAngle: Float,
        endAngle: Float,
        axis: RotationAxis,
        color: PlatformColor,
        radius: Float
    ) {
        let tubeRadius: Float = 0.025
        let arcSegments = 32  // アーク方向の分割数（滑らかさ）
        let tubeSegments = 12 // チューブ断面の分割数

        // カスタムメッシュを生成
        if let mesh = generateTubeMesh(
            startAngle: startAngle,
            endAngle: endAngle,
            axis: axis,
            radius: radius,
            tubeRadius: tubeRadius,
            arcSegments: arcSegments,
            tubeSegments: tubeSegments
        ) {
            var material = SimpleMaterial()
            material.color = .init(tint: color)
            material.roughness = 0.3
            material.metallic = 0.5

            let arcEntity = ModelEntity(mesh: mesh, materials: [material])
            entity.addChild(arcEntity)

            // 端点のマーカー（球）- パイプと同様に半透明
            let endMarkerRadius: Float = 0.035
            let endMarkerMesh = MeshResource.generateSphere(radius: endMarkerRadius)
            var endMaterial = SimpleMaterial()
            endMaterial.color = .init(tint: color.withAlphaComponent(0.6))
            endMaterial.roughness = 0.2
            endMaterial.metallic = 0.7

            let startMarker = ModelEntity(mesh: endMarkerMesh, materials: [endMaterial])
            startMarker.position = calculatePosition(angle: startAngle, axis: axis, radius: radius)
            entity.addChild(startMarker)

            let endMarker = ModelEntity(mesh: endMarkerMesh, materials: [endMaterial])
            endMarker.position = calculatePosition(angle: endAngle, axis: axis, radius: radius)
            entity.addChild(endMarker)
        }
    }

    /// チューブ状のカスタムメッシュを生成
    private static func generateTubeMesh(
        startAngle: Float,
        endAngle: Float,
        axis: RotationAxis,
        radius: Float,
        tubeRadius: Float,
        arcSegments: Int,
        tubeSegments: Int
    ) -> MeshResource? {
        var positions: [SIMD3<Float>] = []
        var normals: [SIMD3<Float>] = []
        var uvs: [SIMD2<Float>] = []
        var indices: [UInt32] = []

        // アークに沿って頂点を生成
        for i in 0...arcSegments {
            let t = Float(i) / Float(arcSegments)
            let arcAngle = startAngle + (endAngle - startAngle) * t

            // アーク上の中心点
            let center = calculatePosition(angle: arcAngle, axis: axis, radius: radius)

            // この点での接線方向を計算
            let tangent = calculateTangent(angle: arcAngle, axis: axis)

            // 法線と従法線を計算（フレネ・セレのフレーム）
            let normal = calculateNormal(angle: arcAngle, axis: axis, radius: radius)
            let binormal = simd_cross(tangent, normal)

            // チューブの断面の頂点を生成
            for j in 0...tubeSegments {
                let tubeAngle = Float(j) / Float(tubeSegments) * 2 * .pi

                // 断面上の点を計算
                let offset = normal * cos(tubeAngle) * tubeRadius + binormal * sin(tubeAngle) * tubeRadius
                let position = center + offset

                positions.append(position)

                // 法線（中心から外向き）
                let vertexNormal = simd_normalize(offset)
                normals.append(vertexNormal)

                // UV座標
                uvs.append(SIMD2<Float>(t, Float(j) / Float(tubeSegments)))
            }
        }

        // インデックスを生成（三角形ストリップ）
        for i in 0..<arcSegments {
            for j in 0..<tubeSegments {
                let current = UInt32(i * (tubeSegments + 1) + j)
                let next = UInt32((i + 1) * (tubeSegments + 1) + j)

                // 2つの三角形で四角形を構成
                indices.append(current)
                indices.append(next)
                indices.append(current + 1)

                indices.append(current + 1)
                indices.append(next)
                indices.append(next + 1)
            }
        }

        // MeshDescriptorを作成
        var descriptor = MeshDescriptor()
        descriptor.positions = MeshBuffer(positions)
        descriptor.normals = MeshBuffer(normals)
        descriptor.textureCoordinates = MeshBuffer(uvs)
        descriptor.primitives = .triangles(indices)

        return try? MeshResource.generate(from: [descriptor])
    }

    /// 角度と軸から3D位置を計算
    private static func calculatePosition(angle: Float, axis: RotationAxis, radius: Float) -> SIMD3<Float> {
        switch axis {
        case .forward:
            // X軸周り - 前後の傾き（うなずき）
            return SIMD3<Float>(
                0,
                radius * sin(angle),
                -radius * cos(angle)
            )
        case .vertical:
            // Y軸周り - 左右を向く
            return SIMD3<Float>(
                radius * sin(angle),
                0,
                -radius * cos(angle)
            )
        case .horizontal:
            // Z軸周り - 左右の傾き（首かしげ）
            return SIMD3<Float>(
                radius * sin(angle),
                radius * cos(angle),
                0
            )
        }
    }

    /// アーク上の接線方向を計算
    private static func calculateTangent(angle: Float, axis: RotationAxis) -> SIMD3<Float> {
        switch axis {
        case .forward:
            // X軸周りの回転の接線
            return simd_normalize(SIMD3<Float>(
                0,
                cos(angle),
                sin(angle)
            ))
        case .vertical:
            // Y軸周りの回転の接線
            return simd_normalize(SIMD3<Float>(
                cos(angle),
                0,
                sin(angle)
            ))
        case .horizontal:
            // Z軸周りの回転の接線
            return simd_normalize(SIMD3<Float>(
                cos(angle),
                -sin(angle),
                0
            ))
        }
    }

    /// アーク上の法線方向を計算（中心から外向き）
    private static func calculateNormal(angle: Float, axis: RotationAxis, radius: Float) -> SIMD3<Float> {
        let position = calculatePosition(angle: angle, axis: axis, radius: radius)
        return simd_normalize(position)
    }
}
