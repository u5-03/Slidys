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
        for row in 0..<rows {
            let t = (Float(row) + 0.5) / Float(rows) * 2 - 1
            let y = TaiyakiDesign.cutCenter.y + t * halfHeight
            let width = (c.mouthOpening * 0.5 - 0.029) * pow(max(0, 1 - pow(abs(t), 4)), 0.5)
            for column in 0..<3 {
                let x = TaiyakiDesign.cutCenter.x + 0.020 * t
                    + (Float(column) - 1) * width * 0.76 + random.signed() * 0.006
                let p = SIMD2<Float>(x, y + random.signed() * 0.006)
                let radius = SIMD3<Float>(0.014 + random.unit() * 0.004,
                                          0.018 + random.unit() * 0.007,
                                          0.012 + random.unit() * 0.005)
                let rotation = simd_quatf(angle: random.signed() * .pi, axis: [0, 0, 1])
                    * simd_quatf(angle: random.signed() * 0.6, axis: [1, 0, 0])
                let z = surface.height(p) - 0.019 + random.signed() * 0.006
                meshes[(row + column) % paletteCount].append(ellipsoid(
                    center: [p.x, p.y, z], radii: radius, rotation: rotation, seed: random.unit()))
            }
        }
        return meshes
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

