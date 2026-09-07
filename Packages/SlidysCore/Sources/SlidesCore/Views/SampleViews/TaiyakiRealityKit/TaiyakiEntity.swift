import Foundation
import RealityKit

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
        let patterns: SurfacePatternBuilder.Result
        let pixels: TaiyakiMaterialFactory.TexturePixels
    }

    static func make(configuration: TaiyakiConfiguration = .init()) async throws -> Result {
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
                            patterns: SurfacePatternBuilder.build(surface: surface, bodyMesh: body),
                            pixels: TaiyakiMaterialFactory.pixels(surface: surface))
        }
        let geometry = await withTaskCancellationHandler {
            await worker.value
        } onCancel: {
            worker.cancel()
        }
        try Task.checkCancellation()
        let pastry = try await TaiyakiMaterialFactory.pastry(pixels: geometry.pixels)
        let root = Entity()
        root.name = "TaiyakiEntity"
        var triangleCount = 0, modelCount = 0
        func add(_ mesh: TaiyakiMesh, name: String, material: PhysicallyBasedMaterial, parent: Entity? = nil) throws {
            let model = ModelEntity(mesh: try mesh.resource(name: name), materials: [material])
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
        for (i, mesh) in geometry.beans.enumerated() {
            try add(mesh, name: "Beans_\(i)", material: TaiyakiMaterialFactory.bean(i), parent: filling)
        }
        try add(geometry.patterns.mold, name: "SurfacePatterns", material: TaiyakiMaterialFactory.mold(c))
        try add(geometry.patterns.eyes, name: "Eye", material: TaiyakiMaterialFactory.mold(c))
        try add(geometry.patterns.logo, name: "Logo", material: TaiyakiMaterialFactory.logo)
        root.scale = .init(repeating: c.bodyLength)
        let bounds = root.visualBounds(relativeTo: nil)
        root.position = -bounds.center
        // A single inexpensive input volume; no per-bean collision shapes.
        root.components.set(InputTargetComponent())
        root.components.set(CollisionComponent(shapes: [
            .generateBox(size: bounds.extents / c.bodyLength).offsetBy(translation: bounds.center / c.bodyLength)
        ], mode: .trigger, filter: .sensor))
        print("[ProceduralTaiyaki] \(triangleCount) triangles, \(modelCount) models; bounds(m): \(bounds.extents)")
        return Result(root: root, triangleCount: triangleCount, modelCount: modelCount, bounds: bounds)
    }
}
