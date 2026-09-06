import Foundation
import simd

enum MouthMeshBuilder {
    /// Superellipse with a gently scalloped broken-pastry edge. The same boundary
    /// is shared by the body's hole, crumb rim, well and bean placement.
    static func boundary(configuration c: TaiyakiConfiguration, count: Int, inset: Float = 0) -> [SIMD2<Float>] {
        (0..<count).map { i in
            let angle = Float(i) / Float(count) * 2 * .pi
            let x = cos(angle), y = sin(angle)
            let scallop = 1 + TaiyakiDesign.cutScallop * sin(13 * angle)
                + TaiyakiDesign.cutFineScallop * sin(21 * angle + 1)
            let halfWidth = c.mouthOpening * 0.5 - inset
            let halfHeight = TaiyakiDesign.cutHalfHeight * c.bodyHeight / 0.67 - inset
            let sx = (x < 0 ? -1 as Float : 1) * pow(abs(x), 0.76)
            let sy = (y < 0 ? -1 as Float : 1) * pow(abs(y), 0.90)
            return TaiyakiDesign.cutCenter + SIMD2<Float>(sx * halfWidth * scallop + 0.020 * sy,
                                                          sy * halfHeight * scallop)
        }
    }

    static func build(surface: TaiyakiBodySurface) -> (crumb: TaiyakiMesh, interior: TaiyakiMesh) {
        let c = surface.configuration, count = c.contourSegments
        let outer = boundary(configuration: c, count: count)
        let inner = boundary(configuration: c, count: count, inset: TaiyakiDesign.crumbWidth)
        var crumb = TaiyakiMesh(), interior = TaiyakiMesh()
        let bevelRings = 5
        for ring in 0...bevelRings {
            let t = Float(ring) / Float(bevelRings)
            for i in 0..<count {
                let p = outer[i] * (1 - t) + inner[i] * t
                // Rolls over the cut edge into a substantial pale bread wall.
                let depth = TaiyakiDesign.cutDepth * t * t
                crumb.vertex([p.x, p.y, surface.height(p) - depth])
            }
        }
        for ring in 0..<bevelRings {
            for i in 0..<count {
                let j = (i + 1) % count
                let a = UInt32(ring * count + i), b = UInt32(ring * count + j)
                let d = UInt32((ring + 1) * count + i), e = UInt32((ring + 1) * count + j)
                crumb.quad(a, b, e, d)
            }
        }
        let center = interior.vertex([TaiyakiDesign.cutCenter.x, TaiyakiDesign.cutCenter.y, 0.010])
        for i in 0..<count {
            let p = inner[i]
            interior.vertex([p.x, p.y, surface.height(p) - TaiyakiDesign.cutDepth])
        }
        for i in 0..<count {
            interior.triangle(center, UInt32(i + 1), UInt32((i + 1) % count + 1))
        }
        return (crumb, interior)
    }
}
