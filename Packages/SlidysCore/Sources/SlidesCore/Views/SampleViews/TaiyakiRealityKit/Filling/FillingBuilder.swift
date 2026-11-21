import Foundation
import simd

enum FillingBuilder {
    static let paletteCount = 4

    static func build(surface: TaiyakiBodySurface) -> [TaiyakiMesh] {
        let c = surface.configuration
        var meshes = Array(repeating: TaiyakiMesh(), count: paletteCount)
        var random = TaiyakiRandom(state: c.seed)
        let rows = Int(23 * c.fillingAmount)
        let halfHeight = TaiyakiDesign.cutHalfHeight * c.bodyHeight / 0.67 - 0.035
        let inner = MouthMeshBuilder.boundary(configuration: c, count: c.contourSegments,
                                               inset: TaiyakiDesign.crumbWidth)
        for row in 0..<rows {
            let t = (Float(row) + 0.5) / Float(rows) * 2 - 1
            let y = TaiyakiDesign.cutCenter.y + t * halfHeight
            guard let span = MouthMeshBuilder.horizontalSpan(at: y, contour: inner) else { continue }
            let columns = max(1, min(4, Int((span.upperBound - span.lowerBound) / 0.030)))
            for column in 0..<columns {
                let py = y + random.signed() * 0.003
                guard let local = MouthMeshBuilder.horizontalSpan(at: py, contour: inner) else { continue }
                let halfWidth = (local.upperBound - local.lowerBound) * 0.5
                let size = min(1, max(0.15, (halfWidth - 0.003) / 0.026))
                let radius = SIMD3<Float>(0.014 + random.unit() * 0.004,
                                          0.018 + random.unit() * 0.007,
                                          0.012 + random.unit() * 0.005) * size
                let available = max(0, halfWidth - max(radius.x, radius.y) - 0.003)
                let u = columns == 1 ? Float(0) : Float(column) / Float(columns - 1) * 2 - 1
                let jitter = random.signed() * min(0.002, available * 0.1)
                let x = (local.lowerBound + local.upperBound) * 0.5
                    + max(-available, min(available, u * available + jitter))
                let p = SIMD2<Float>(x, py)
                let rotation = simd_quatf(angle: random.signed() * .pi, axis: [0, 0, 1])
                    * simd_quatf(angle: random.signed() * 0.6, axis: [1, 0, 0])
                let z = surface.height(p) - 0.019 + random.signed() * 0.006
                meshes[(row + column) % paletteCount].append(ellipsoid(
                    center: [p.x, p.y, z], radii: radius, rotation: rotation, seed: random.unit()))
            }
        }
        return meshes
    }

    /// A smooth filling surface following the same mouth opening as the beans.
    static func smooth(surface: TaiyakiBodySurface) -> TaiyakiMesh {
        let boundary = MouthMeshBuilder.boundary(configuration: surface.configuration, count: 64,
                                                  inset: TaiyakiDesign.crumbWidth)
        let center = TaiyakiDesign.cutCenter
        let rings = 8
        var mesh = TaiyakiMesh()
        func point(_ p: SIMD2<Float>, radius: Float) -> SIMD3<Float> {
            [p.x, p.y, surface.height(p) - 0.015 + 0.020 * (1 - radius * radius)]
        }
        let middle = mesh.vertex(point(center, radius: 0))
        for ring in 1...rings {
            let radius = Float(ring) / Float(rings)
            for edge in boundary {
                mesh.vertex(point(center + (edge - center) * radius, radius: radius))
            }
        }
        func front(_ a: UInt32, _ b: UInt32, _ c: UInt32) {
            let normal = simd_cross(mesh.positions[Int(b)] - mesh.positions[Int(a)],
                                    mesh.positions[Int(c)] - mesh.positions[Int(a)])
            mesh.triangle(a, b, c, reversed: normal.z < 0)
        }
        let count = boundary.count
        for i in 0..<count {
            let j = (i + 1) % count
            front(middle, UInt32(1 + i), UInt32(1 + j))
            for ring in 0..<(rings - 1) {
                let a = UInt32(1 + ring * count + i), b = UInt32(1 + ring * count + j)
                front(a, a + UInt32(count), b)
                front(b, a + UInt32(count), b + UInt32(count))
            }
        }
        return mesh
    }

    /// An asymmetric bean with a shallow hilum-like crease, not a copied sphere.
    static func ellipsoid(center: SIMD3<Float>, radii: SIMD3<Float>, rotation: simd_quatf,
                          seed: Float = 0, segments: Int = 12, rings: Int = 8) -> TaiyakiMesh {
        var mesh = TaiyakiMesh()
        let top = mesh.vertex(center + rotation.act([0, radii.y, 0]))
        for ring in 1..<rings {
            let phi = Float(ring) / Float(rings) * .pi
            for i in 0..<segments {
                let theta = Float(i) / Float(segments) * 2 * .pi
                let crease = 1 - 0.09 * exp(-pow(sin(theta) / 0.22, 2)) * sin(phi)
                let irregularity = 1 + 0.045 * sin(theta * 3 + seed * 6) * sin(phi * 2)
                let p = SIMD3<Float>(sin(phi) * cos(theta) * crease,
                                     cos(phi), sin(phi) * sin(theta)) * radii * irregularity
                mesh.vertex(center + rotation.act(p))
            }
        }
        let bottom = mesh.vertex(center + rotation.act([0, -radii.y, 0]))
        for i in 0..<segments {
            let j = (i + 1) % segments
            mesh.triangle(top, UInt32(j + 1), UInt32(i + 1))
            for ring in 0..<(rings - 2) {
                let a = UInt32(1 + ring * segments + i), b = UInt32(1 + ring * segments + j)
                mesh.quad(a, b, b + UInt32(segments), a + UInt32(segments))
            }
            mesh.triangle(bottom, UInt32(1 + (rings - 2) * segments + i), UInt32(1 + (rings - 2) * segments + j))
        }
        return mesh
    }
}

