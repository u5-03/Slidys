import Foundation
import simd

/// Shared continuous surface evaluator: details and the cut rim use the same
/// function as the body, so changing its proportions cannot leave floating decals.
struct TaiyakiBodySurface: Sendable {
    let configuration: TaiyakiConfiguration
    let contour: [SIMD2<Float>]
    private let radialTable: [Float]

    init(_ configuration: TaiyakiConfiguration) {
        self.configuration = configuration
        let sampledContour = TaiyakiCurves.spline(TaiyakiDesign.bodyContour.map { p in
            let headWeight = max(0, min(1, -p.x / 0.30))
            return SIMD2(p.x, p.y * configuration.bodyHeight / 0.67
                         * (1 + (configuration.headScale - 1) * headWeight))
        }, closed: true)
        contour = sampledContour
        radialTable = (0..<720).map { i in
            let angle = Float(i) / 720 * 2 * .pi
            return TaiyakiCurves.radius(from: TaiyakiDesign.bodyCenter,
                                       direction: [cos(angle), sin(angle)], contour: sampledContour)
        }
    }

    func radialFraction(_ point: SIMD2<Float>) -> Float {
        let delta = point - TaiyakiDesign.bodyCenter
        var angle = atan2(delta.y, delta.x)
        if angle < 0 { angle += 2 * .pi }
        let index = angle / (2 * .pi) * Float(radialTable.count)
        let i = Int(index) % radialTable.count
        let t = index - floor(index)
        let radius = radialTable[i] * (1 - t) + radialTable[(i + 1) % radialTable.count] * t
        return simd_length(delta) / radius
    }

    func height(_ p: SIMD2<Float>) -> Float {
        let c = configuration
        let r = min(1, radialFraction(p))
        let dome = max(0, 1 - r * r)
        let head = exp(-pow((p.x + 0.27) / 0.25, 2) - pow((p.y - 0.03) / 0.32, 2))
        let belly = exp(-pow((p.x + 0.03) / 0.28, 2) - pow((p.y + 0.19) / 0.16, 2))
        let taper = 1 - c.tailTaper * smoothstep(0.03, 0.47, p.x)
        let thickness = c.bodyThickness * 0.5 * taper * (1 + c.headBulge * head + c.bellyBulge * belly)
        return c.edgeThickness * 0.5 * sqrt(dome)
            + (thickness - c.edgeThickness * 0.5) * pow(dome, c.bodyCrown)
    }

    func point(_ p: SIMD2<Float>, side: Float = 1, offset: Float = 0) -> SIMD3<Float> {
        [p.x, p.y, side * (height(p) + offset)]
    }

    func normal(_ p: SIMD2<Float>, side: Float) -> SIMD3<Float> {
        let e: Float = 0.0005
        let dx = (height(p + [e, 0]) - height(p - [e, 0])) / (2 * e)
        let dy = (height(p + [0, e]) - height(p - [0, e])) / (2 * e)
        return simd_normalize([-dx, -dy, side])
    }

    private func smoothstep(_ a: Float, _ b: Float, _ x: Float) -> Float {
        let t = max(0, min(1, (x - a) / (b - a)))
        return t * t * (3 - 2 * t)
    }
}

enum BodyMeshBuilder {
    static func build(surface: TaiyakiBodySurface) -> TaiyakiMesh {
        let c = surface.configuration
        let count = c.contourSegments, rings = c.bodyRings
        let cut = MouthMeshBuilder.boundary(configuration: c, count: count)
        let center = TaiyakiDesign.cutCenter
        var mesh = TaiyakiMesh()
        var outer: [SIMD2<Float>] = []
        // The front is an annulus. No hidden body triangles span the opening.
        for i in 0..<count {
            // Uniform outer angles preserve the rounded nose. Using the tall,
            // narrow cut's rays here starved the forehead and lips of vertices.
            let angle = Float(i) / Float(count) * 2 * .pi
            let d = SIMD2<Float>(cos(angle), sin(angle))
            outer.append(center + d * TaiyakiCurves.radius(from: center, direction: d, contour: surface.contour))
        }
        for ring in 0...rings {
            let t = Float(ring) / Float(rings)
            // Cosine sampling adds geometry around the rounded outer edge.
            let s = sin(t * .pi * 0.5)
            for i in 0..<count {
                let p = cut[i] * (1 - s) + outer[i] * s
                mesh.vertex(surface.point(p))
            }
        }
        for ring in 0..<rings {
            for i in 0..<count {
                let next = (i + 1) % count
                let a = UInt32(ring * count + i), b = UInt32(ring * count + next)
                let d = UInt32((ring + 1) * count + i), e = UInt32((ring + 1) * count + next)
                mesh.quad(a, d, e, b)
            }
        }
        // The back is unbroken. Share the perimeter with the front for continuous
        // normals and a watertight edge, rather than two disconnected extrusions.
        let backCenter = mesh.vertex(surface.point(center, side: -1))
        var previous: [UInt32] = []
        for ring in 1...rings {
            let t = sin(Float(ring) / Float(rings) * .pi * 0.5)
            var current: [UInt32] = []
            for i in 0..<count {
                current.append(ring == rings ? UInt32(rings * count + i)
                               : mesh.vertex(surface.point(center * (1 - t) + outer[i] * t, side: -1)))
            }
            for i in 0..<count {
                let j = (i + 1) % count
                if ring == 1 { mesh.triangle(backCenter, current[j], current[i]) }
                else { mesh.quad(previous[i], previous[j], current[j], current[i]) }
            }
            previous = current
        }
        return mesh
    }
}
