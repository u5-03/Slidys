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

/// A small spatial index of the actual tessellated shell. Near the rolled edge,
/// the analytic dome and its triangles differ enough to swallow shallow marks.
/// Barycentric projection keeps the embossing seated on the rendered surface.
struct TaiyakiBodyProjection {
    private let mesh: TaiyakiMesh
    private let surface: TaiyakiBodySurface
    private let minimum: SIMD2<Float>
    private let extent: SIMD2<Float>
    private let resolution = 32
    private var cells: [[Int]]

    init(mesh: TaiyakiMesh, surface: TaiyakiBodySurface) {
        self.mesh = mesh
        self.surface = surface
        var lower = SIMD2<Float>(repeating: .greatestFiniteMagnitude)
        var upper = SIMD2<Float>(repeating: -.greatestFiniteMagnitude)
        for p in mesh.positions {
            lower = simd_min(lower, [p.x, p.y])
            upper = simd_max(upper, [p.x, p.y])
        }
        minimum = lower
        extent = upper - lower
        cells = Array(repeating: [], count: resolution * resolution)
        for i in stride(from: 0, to: mesh.triangles.count, by: 3) {
            let a = mesh.positions[Int(mesh.triangles[i])]
            let b = mesh.positions[Int(mesh.triangles[i + 1])]
            let c = mesh.positions[Int(mesh.triangles[i + 2])]
            let lo = grid(simd_min([a.x, a.y], simd_min([b.x, b.y], [c.x, c.y])))
            let hi = grid(simd_max([a.x, a.y], simd_max([b.x, b.y], [c.x, c.y])))
            for y in lo.y...hi.y {
                for x in lo.x...hi.x { cells[y * resolution + x].append(i) }
            }
        }
    }

    func point(_ p: SIMD2<Float>, side: Float) -> SIMD3<Float> {
        let cell = grid(p)
        func cross(_ a: SIMD2<Float>, _ b: SIMD2<Float>) -> Float { a.x * b.y - a.y * b.x }
        for i in cells[cell.y * resolution + cell.x] {
            let a = mesh.positions[Int(mesh.triangles[i])]
            let b = mesh.positions[Int(mesh.triangles[i + 1])]
            let c = mesh.positions[Int(mesh.triangles[i + 2])]
            let ab = SIMD2<Float>(b.x - a.x, b.y - a.y)
            let ac = SIMD2<Float>(c.x - a.x, c.y - a.y)
            let ap = p - SIMD2<Float>(a.x, a.y)
            let determinant = cross(ab, ac)
            guard determinant * side > 1e-12 else { continue }
            let u = cross(ap, ac) / determinant
            let v = cross(ab, ap) / determinant
            if u >= -1e-5, v >= -1e-5, u + v <= 1.00001 {
                return [p.x, p.y, a.z + (b.z - a.z) * u + (c.z - a.z) * v]
            }
        }
        return surface.point(p, side: side)
    }

    private func grid(_ p: SIMD2<Float>) -> SIMD2<Int> {
        let uv = simd_clamp((p - minimum) / extent, .zero, .one) * Float(resolution - 1)
        return [Int(uv.x), Int(uv.y)]
    }
}
