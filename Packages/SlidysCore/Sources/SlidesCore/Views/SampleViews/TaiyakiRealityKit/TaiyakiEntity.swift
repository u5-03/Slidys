import Foundation
import RealityKit
import OSLog

private let taiyakiBuildLogger = Logger(subsystem: "Slidys", category: "PresenterCapture")

func taiyakiBuildTrace(_ message: String) {
    taiyakiBuildLogger.notice("[PresenterCapture] taiyaki \(message, privacy: .public)")
}

/// All mesh and pixel generation is pure Swift. RealityKit upload happens once;
/// subsequent interaction changes only the root transform.
@MainActor
enum TaiyakiEntity {
    struct Result {
        let root: Entity
        let triangleCount: Int
        let modelCount: Int
        let bounds: BoundingBox
    }

    private struct Geometry: Sendable {
        let body: TaiyakiMesh
        let tail: TaiyakiMesh
        let dorsal: TaiyakiMesh
        let ventral: TaiyakiMesh
        let crumb: TaiyakiMesh
        let interior: TaiyakiMesh
        let beans: [TaiyakiMesh]
        let smoothFilling: TaiyakiMesh
        let patterns: SurfacePatternBuilder.Result
        let pixels: TaiyakiMaterialFactory.TexturePixels
    }

    static func make(configuration: TaiyakiConfiguration = .init()) async throws -> Result {
        taiyakiBuildTrace("build begin")
        let c = configuration.validated
        let worker = Task.detached(priority: .userInitiated) {
            let surface = TaiyakiBodySurface(c)
            let body = BodyMeshBuilder.build(surface: surface)
            let mouth = MouthMeshBuilder.build(surface: surface)
            return Geometry(body: body,
                            tail: TailMeshBuilder.build(c),
                            dorsal: FinMeshBuilder.build(FinMeshBuilder.dorsal(c)),
                            ventral: FinMeshBuilder.build(FinMeshBuilder.ventral(c)),
                            crumb: mouth.crumb, interior: mouth.interior,
                            beans: FillingBuilder.build(surface: surface),
                            smoothFilling: FillingBuilder.smooth(surface: surface),
                            patterns: SurfacePatternBuilder.build(surface: surface, bodyMesh: body),
                            pixels: TaiyakiMaterialFactory.pixels(surface: surface))
        }
        let geometry = await withTaskCancellationHandler {
            await worker.value
        } onCancel: {
            worker.cancel()
        }
        try Task.checkCancellation()
        taiyakiBuildTrace("geometry ready textureSize=\(geometry.pixels.size)")
        let pastry = try await TaiyakiMaterialFactory.pastry(pixels: geometry.pixels)
        taiyakiBuildTrace("textures uploaded")
        let root = Entity()
        root.name = "TaiyakiEntity"
        var triangleCount = 0, modelCount = 0
        func add(_ mesh: TaiyakiMesh, name: String, material: PhysicallyBasedMaterial, parent: Entity? = nil) throws {
            // Apply the same smooth head extension to shell and facial marks;
            // normals are regenerated from the deformed vertices on upload.
            var shaped = mesh
            shaped.positions = mesh.positions.map { p in
                let weight = max(0, -p.x / 0.52)
                return SIMD3<Float>(p.x - c.headExtension * weight * weight, p.y, p.z)
            }
            taiyakiBuildTrace("mesh upload begin name=\(name) vertices=\(shaped.positions.count) indices=\(shaped.triangles.count)")
            let model = ModelEntity(mesh: try shaped.resource(name: name), materials: [material])
            taiyakiBuildTrace("mesh upload end name=\(name)")
            model.name = name
            (parent ?? root).addChild(model)
            triangleCount += mesh.triangles.count / 3
            modelCount += 1
        }
        try add(geometry.body, name: "Body", material: pastry)
        try add(geometry.tail, name: "Tail", material: pastry)
        try add(geometry.dorsal, name: "DorsalFin", material: pastry)
        try add(geometry.ventral, name: "VentralFin", material: pastry)
        let mouth = Entity(); mouth.name = "Mouth"; root.addChild(mouth)
        try add(geometry.crumb, name: "CrumbRim", material: TaiyakiMaterialFactory.crumb, parent: mouth)
        try add(geometry.interior, name: "RecessedInterior", material: TaiyakiMaterialFactory.interior, parent: mouth)
        let filling = Entity(); filling.name = "Filling"; root.addChild(filling)
        let beans = Entity()
        beans.name = TaiyakiFilling.redBeans.rawValue
        filling.addChild(beans)
        for (i, mesh) in geometry.beans.enumerated() {
            try add(mesh, name: "Beans_\(i)", material: TaiyakiMaterialFactory.bean(i), parent: beans)
        }
        for kind in [TaiyakiFilling.custard, .matcha, .chocolate] {
            let variant = Entity()
            variant.name = kind.rawValue
            filling.addChild(variant)
            try add(geometry.smoothFilling, name: "Smooth_\(kind.rawValue)",
                    material: TaiyakiMaterialFactory.smoothFilling(kind), parent: variant)
            variant.isEnabled = false
        }
        try add(geometry.patterns.mold, name: "SurfacePatterns", material: TaiyakiMaterialFactory.mold(c))
        try add(geometry.patterns.eyes, name: "Eye", material: TaiyakiMaterialFactory.mold(c))
        try add(geometry.patterns.logo, name: "Logo", material: TaiyakiMaterialFactory.logo)
        // Emptyと同じローカル目印。ワールド固定のAnchorEntityではない。
        // 生成済みの部位の正面側を目安に置き、親の変形・回転・拡大に追従させる。
        for (part, name) in [(TaiyakiPart.eye, "Eye"), (.tail, "Tail"),
                             (.dorsalFin, "DorsalFin"), (.logo, "Logo"),
                             (.filling, "Filling")] {
            guard let model = root.findEntity(named: name) else { continue }
            let bounds = model.visualBounds(relativeTo: root)
            let anchor = Entity()
            anchor.name = part.rawValue
            anchor.position = [bounds.center.x, bounds.center.y, bounds.max.z]
            root.addChild(anchor)
        }
        root.scale = .init(repeating: c.bodyLength)
        let bounds = root.visualBounds(relativeTo: nil)
        root.position = -bounds.center
        // A single inexpensive input volume; no per-bean collision shapes.
        root.components.set(InputTargetComponent())
        root.components.set(CollisionComponent(shapes: [
            .generateBox(size: bounds.extents / c.bodyLength).offsetBy(translation: bounds.center / c.bodyLength)
        ], mode: .trigger, filter: .sensor))
        print("[ProceduralTaiyaki] \(triangleCount) triangles, \(modelCount) models; bounds(m): \(bounds.extents)")
        taiyakiBuildTrace("build end models=\(modelCount) triangles=\(triangleCount)")
        return Result(root: root, triangleCount: triangleCount, modelCount: modelCount, bounds: bounds)
    }
}
