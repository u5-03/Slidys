import RealityKit
import simd

/// CPU-only mesh data. Every visible component ultimately uses MeshDescriptor.
struct TaiyakiMesh: Sendable {
    var positions: [SIMD3<Float>] = []
    var uvs: [SIMD2<Float>] = []
    var triangles: [UInt32] = []

    @discardableResult
    mutating func vertex(_ p: SIMD3<Float>) -> UInt32 {
        let index = UInt32(positions.count)
        positions.append(p)
        uvs.append([(p.x + 0.6) / 1.5, (p.y + 0.5) / 1.1])
        return index
    }

    mutating func triangle(_ a: UInt32, _ b: UInt32, _ c: UInt32, reversed: Bool = false) {
        triangles += reversed ? [a, c, b] : [a, b, c]
    }

    mutating func quad(_ a: UInt32, _ b: UInt32, _ c: UInt32, _ d: UInt32, reversed: Bool = false) {
        triangle(a, b, c, reversed: reversed)
        triangle(a, c, d, reversed: reversed)
    }

    mutating func append(_ other: Self) {
        let offset = UInt32(positions.count)
        positions += other.positions
        uvs += other.uvs
        triangles += other.triangles.map { $0 + offset }
    }

    func normals() -> [SIMD3<Float>] {
        var result = Array(repeating: SIMD3<Float>.zero, count: positions.count)
        for i in stride(from: 0, to: triangles.count, by: 3) {
            let a = Int(triangles[i]), b = Int(triangles[i + 1]), c = Int(triangles[i + 2])
            let n = simd_cross(positions[b] - positions[a], positions[c] - positions[a])
            result[a] += n; result[b] += n; result[c] += n
        }
        return result.map { simd_length_squared($0) > 1e-16 ? simd_normalize($0) : [0, 0, 1] }
    }

    @MainActor
    func resource(name: String) throws -> MeshResource {
        var descriptor = MeshDescriptor(name: name)
        descriptor.positions = .init(positions)
        descriptor.normals = .init(normals())
        descriptor.textureCoordinates = .init(uvs)
        descriptor.primitives = .triangles(triangles)
        return try MeshResource.generate(from: [descriptor])
    }
}

enum TaiyakiCurves {
    static func spline(_ points: [SIMD2<Float>], subdivisions: Int = 8, closed: Bool = false) -> [SIMD2<Float>] {
        guard points.count > 1 else { return points }
        var result: [SIMD2<Float>] = []
        func point(_ i: Int) -> SIMD2<Float> {
            points[closed ? (i + points.count) % points.count : min(points.count - 1, max(0, i))]
        }
        for i in 0..<(closed ? points.count : points.count - 1) {
            let a = point(i - 1), b = point(i), c = point(i + 1), d = point(i + 2)
            for j in 0..<subdivisions {
                let t = Float(j) / Float(subdivisions)
                let linear = (c - a) * t
                let q1: SIMD2<Float> = a * Float(2) - b * Float(5)
                let q2: SIMD2<Float> = c * Float(4) - d
                let quadratic: SIMD2<Float> = (q1 + q2) * (t * t)
                let c1: SIMD2<Float> = b * Float(3) - a
                let c2: SIMD2<Float> = d - c * Float(3)
                let cubic: SIMD2<Float> = (c1 + c2) * (t * t * t)
                let value: SIMD2<Float> = b * Float(2) + linear + quadratic + cubic
                result.append(value * Float(0.5))
            }
        }
        if !closed { result.append(points.last!) }
        return result
    }

    /// Intersection of a ray with a star-shaped sampled contour.
    static func radius(from center: SIMD2<Float>, direction d: SIMD2<Float>, contour: [SIMD2<Float>]) -> Float {
        var best: Float = .greatestFiniteMagnitude
        func cross(_ a: SIMD2<Float>, _ b: SIMD2<Float>) -> Float { a.x * b.y - a.y * b.x }
        for i in contour.indices {
            let a = contour[i] - center
            let edge = contour[(i + 1) % contour.count] - contour[i]
            let denominator = cross(d, edge)
            guard abs(denominator) > 1e-7 else { continue }
            let t = cross(a, edge) / denominator
            let u = cross(a, d) / denominator
            if t > 0, u >= 0, u <= 1 { best = min(best, t) }
        }
        return best.isFinite && best < 10 ? best : 0.001
    }
}

struct TaiyakiRandom: Sendable {
    var state: UInt64
    mutating func unit() -> Float {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return Float(UInt32(truncatingIfNeeded: state >> 32)) / Float(UInt32.max)
    }
    mutating func signed() -> Float { unit() * 2 - 1 }
}
