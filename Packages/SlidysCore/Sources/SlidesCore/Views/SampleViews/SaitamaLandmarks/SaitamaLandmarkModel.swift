import CoreGraphics
import Foundation
import RealityKit
import simd

/// Photo-referenced interpretations, not survey-accurate architectural replicas.
/// All geometry and surface textures are generated locally in Swift.
/// Visual references (viewed 2026-11-03; photos are not bundled or used as textures):
/// Gyoda: https://www.ikiiki-zaidan.or.jp/kodaihasu/facility/images/tower.jpg
/// Toki no Kane: https://www.princehotels.co.jp/kawagoe/experience/common/img/img_spot01.jpg
/// Museum: https://christinayan01.jp/architecture/archives/15649
/// Back faces, roof details and unseen parts are plausible approximations.
public enum SaitamaLandmark: String, CaseIterable, Identifiable {
    case gyodaTower, tokiNoKane, kadokawaMuseum
    public var id: String { rawValue }

}

private struct LandmarkMesh {
    var points: [SIMD3<Float>] = []
    var normals: [SIMD3<Float>] = []
    var uv: [SIMD2<Float>] = []
    var indices: [UInt32] = []

    mutating func quad(_ a: SIMD3<Float>, _ b: SIMD3<Float>, _ c: SIMD3<Float>, _ d: SIMD3<Float>,
                       uvScale: SIMD2<Float> = [1, 1]) {
        var cross = simd_cross(b - a, c - a)
        if simd_length_squared(cross) < 1e-12 { cross = simd_cross(c - a, d - a) }
        guard simd_length_squared(cross) > 1e-12 else { return }
        let n = simd_normalize(cross)
        let i = UInt32(points.count)
        points += [a, b, c, d]
        normals += Array(repeating: n, count: 4)
        uv += [[0, 0], [uvScale.x, 0], uvScale, [0, uvScale.y]]
        indices += [i, i + 1, i + 2, i, i + 2, i + 3]
    }

    mutating func box(center p: SIMD3<Float>, size s: SIMD3<Float>) {
        let lo = p - s / 2, hi = p + s / 2
        quad([lo.x, lo.y, hi.z], [hi.x, lo.y, hi.z], [hi.x, hi.y, hi.z], [lo.x, hi.y, hi.z])
        quad([hi.x, lo.y, lo.z], [lo.x, lo.y, lo.z], [lo.x, hi.y, lo.z], [hi.x, hi.y, lo.z])
        quad([hi.x, lo.y, hi.z], [hi.x, lo.y, lo.z], [hi.x, hi.y, lo.z], [hi.x, hi.y, hi.z])
        quad([lo.x, lo.y, lo.z], [lo.x, lo.y, hi.z], [lo.x, hi.y, hi.z], [lo.x, hi.y, lo.z])
        quad([lo.x, hi.y, hi.z], [hi.x, hi.y, hi.z], [hi.x, hi.y, lo.z], [lo.x, hi.y, lo.z])
        quad([lo.x, lo.y, lo.z], [hi.x, lo.y, lo.z], [hi.x, lo.y, hi.z], [lo.x, lo.y, hi.z])
    }

    @MainActor func resource(_ name: String) throws -> MeshResource {
        guard points.allSatisfy({ $0.x.isFinite && $0.y.isFinite && $0.z.isFinite }),
              normals.allSatisfy({ $0.x.isFinite && $0.y.isFinite && $0.z.isFinite }) else {
            throw CocoaError(.coderInvalidValue)
        }
        var d = MeshDescriptor(name: name)
        d.positions = .init(points)
        d.normals = .init(normals)
        d.textureCoordinates = .init(uv)
        d.primitives = .triangles(indices)
        return try MeshResource.generate(from: [d])
    }
}

@MainActor
struct SaitamaLandmarkModel {
    let root: Entity
    let triangleCount: Int

    static func make(_ landmark: SaitamaLandmark) throws -> Self {
        let builder = LandmarkBuilder()
        switch landmark {
        case .gyodaTower: builder.gyoda()
        case .tokiNoKane: builder.bellTower()
        case .kadokawaMuseum: builder.museum()
        }
        let root = Entity()
        root.name = landmark.rawValue
        var count = 0
        for style in LandmarkSurface.allCases {
            guard let mesh = builder.meshes[style], !mesh.points.isEmpty else { continue }
            let model = ModelEntity(mesh: try mesh.resource(style.rawValue), materials: [try style.material()])
            model.name = style.rawValue
            root.addChild(model)
            count += mesh.indices.count / 3
        }
        let bounds = root.visualBounds(relativeTo: root)
        let wrapper = Entity()
        // The same two-unit bounding sphere fits every building, including tall towers.
        let scale: Float = 2 / simd_length(bounds.extents)
        root.position = -bounds.center * scale
        root.scale = .init(repeating: scale)
        wrapper.addChild(root)
        // One simple hit volume avoids thousands of collision triangles for masonry.
        wrapper.components.set(CollisionComponent(shapes: [.generateBox(size: bounds.extents * scale)]))
        wrapper.components.set(InputTargetComponent())
        return Self(root: wrapper, triangleCount: count)
    }
}

private enum LandmarkSurface: String, CaseIterable {
    case concrete, trim, glass, darkGlass, wood, woodLight, bronze, copper, roofPatina, stone, stoneLight, stoneDark, paving
    var rgb: SIMD3<Float> {
        switch self {
        case .concrete: [0.66, 0.69, 0.67]
        case .trim: [0.47, 0.47, 0.43]
        case .glass: [0.22, 0.38, 0.43]
        case .darkGlass: [0.08, 0.14, 0.17]
        case .wood: [0.28, 0.20, 0.12]
        case .woodLight: [0.43, 0.34, 0.22]
        case .bronze: [0.22, 0.27, 0.20]
        case .copper: [0.32, 0.36, 0.32]
        case .roofPatina: [0.38, 0.43, 0.38]
        case .stone: [0.39, 0.41, 0.40]
        case .stoneLight: [0.49, 0.50, 0.47]
        case .stoneDark: [0.29, 0.32, 0.32]
        case .paving: [0.56, 0.55, 0.51]
        }
    }

    @MainActor func material() throws -> PhysicallyBasedMaterial {
        var m = PhysicallyBasedMaterial()
        let isGlass = self == .glass || self == .darkGlass
        let isWood = self == .wood || self == .woodLight
        let side = 128
        var pixels = [UInt8](repeating: 255, count: side * side * 4)
        var rng = LandmarkRandom(seed: 52)
        for y in 0..<side {
            for x in 0..<side {
                let noise = (rng.next() - 0.5) * (isGlass ? 0.025 : 0.14)
                let grain: Float = isWood ? 0.055 * sin(Float(x) * 0.7 + sin(Float(y) * 0.035) * 1.7) : 0
                let edge: Float = !isGlass && (x < 2 || y < 2) ? -0.07 : 0
                let color = rgb + SIMD3<Float>(repeating: noise + grain + edge)
                let offset = (y * side + x) * 4
                for c in 0..<3 { pixels[offset + c] = UInt8(max(0, min(255, color[c] * 255))) }
            }
        }
        let data = Data(pixels) as CFData
        guard let provider = CGDataProvider(data: data),
              let image = CGImage(width: side, height: side, bitsPerComponent: 8, bitsPerPixel: 32,
                                  bytesPerRow: side * 4, space: CGColorSpaceCreateDeviceRGB(),
                                  bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue),
                                  provider: provider, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
        else { throw CocoaError(.coderInvalidValue) }
        let texture = try TextureResource(image: image, options: .init(semantic: .color))
        m.baseColor = .init(texture: .init(texture))
        m.roughness = .init(floatLiteral: isGlass ? 0.22 : 0.86)
        m.metallic = .init(floatLiteral: isGlass ? 0.35 : (self == .bronze || self == .copper ? 0.45 : 0))
        return m
    }
}

private struct LandmarkRandom {
    var seed: UInt64
    mutating func next() -> Float {
        seed = seed &* 6364136223846793005 &+ 1442695040888963407
        return Float(UInt32(truncatingIfNeeded: seed >> 32)) / Float(UInt32.max)
    }
}

private final class LandmarkBuilder {
    var meshes: [LandmarkSurface: LandmarkMesh] = [:]
    func box(_ style: LandmarkSurface, _ p: SIMD3<Float>, _ size: SIMD3<Float>) {
        meshes[style, default: LandmarkMesh()].box(center: p, size: size)
    }
    func face(_ style: LandmarkSurface, _ a: SIMD3<Float>, _ b: SIMD3<Float>, _ c: SIMD3<Float>, _ d: SIMD3<Float>) {
        meshes[style, default: LandmarkMesh()].quad(a, b, c, d)
    }

    /// Lathed profile: closed rings, capped at top and bottom; axis is Y.
    func lathe(_ style: LandmarkSurface, profile: [(Float, Float)], segments: Int = 48,
               center: SIMD3<Float> = .zero, stretch: SIMD2<Float> = [1, 1]) {
        for j in 0..<(profile.count - 1) {
            for i in 0..<segments {
                func p(_ ring: Int, _ sector: Int) -> SIMD3<Float> {
                    let a = Float(sector) / Float(segments) * .pi * 2
                    return center + [cos(a) * profile[ring].0 * stretch.x, profile[ring].1,
                                     sin(a) * profile[ring].0 * stretch.y]
                }
                face(style, p(j, i), p(j + 1, i), p(j + 1, i + 1), p(j, i + 1))
            }
        }
    }

    func gyoda() {
        // Pale shaft, vertical ribs, dark glazed observation deck and projecting roof.
        box(.paving, [0, 0.12, 0], [14, 0.24, 12])
        box(.concrete, [0, 1.8, 0], [12, 3.5, 8])
        box(.trim, [0, 3.6, 0], [13.2, 0.28, 9])
        for x in stride(from: Float(-5.5), through: 5.5, by: 1.1) {
            box(.glass, [x, 1.9, 4.02], [0.9, 2.2, 0.08])
            box(.trim, [x + 0.48, 1.9, 4.08], [0.07, 2.4, 0.12])
        }
        // The shaft has a flat-sided concrete core and a darker elevator strip.
        box(.concrete, [0, 23.3, 0], [3.5, 40, 3.0])
        box(.darkGlass, [0, 23.3, 1.52], [0.58, 39.5, 0.06])
        for x: Float in [-1.7, 1.7] {
            box(.trim, [x, 23.3, 1.52], [0.12, 40, 0.12])
            box(.trim, [x, 23.3, -1.52], [0.12, 40, 0.12])
        }
        lathe(.concrete, profile: [(1.9, 41.5), (3.8, 43), (4.1, 43.5)], stretch: [1, 0.8])
        lathe(.trim, profile: [(4.1, 43.3), (4.1, 44.1)], stretch: [1, 0.8])
        lathe(.glass, profile: [(3.85, 44.1), (3.85, 48)], stretch: [1, 0.8])
        for i in 0..<24 {
            let a = Float(i) / 24 * .pi * 2
            box(.concrete, [3.9 * cos(a), 46, 3.12 * sin(a)], [0.10, 4.1, 0.10])
        }
        lathe(.concrete, profile: [(4.0, 47.9), (4.45, 48.3), (4.45, 48.6), (0.02, 49.5)], stretch: [1, 0.8])
        lathe(.trim, profile: [(4.45, 48.3), (4.45, 48.6)], stretch: [1, 0.8])
        // Photo shows a broad rectangular rooftop equipment housing, not an antenna.
        box(.concrete, [0, 49.55, 0], [2.7, 0.95, 1.8])
        box(.trim, [0, 50.05, 0], [2.85, 0.12, 1.95])
        for i in 0..<5 {
            box(.trim, [0, 49.2 + Float(i) * 0.15, 0.92], [2.5, 0.035, 0.04])
        }
        // Fine horizontal mullions across the observation room.
        for y: Float in [45.1, 46.1, 47.1] {
            lathe(.trim, profile: [(3.89, y), (3.89, y + 0.045)], stretch: [1, 0.8])
        }
    }

    func bellTower() {
        box(.paving, [0, 0.12, 0], [6.5, 0.24, 6.5])
        // Open pedestrian passage under the tower.
        for x: Float in [-1.8, 1.8] {
            for z: Float in [-1.8, 1.8] {
                box(.wood, [x, 2.05, z], [0.38, 3.9, 0.38])
                box(.stone, [x, 0.32, z], [0.65, 0.4, 0.65])
            }
        }
        box(.wood, [0, 3.85, 0], [4.2, 0.38, 4.2])
        // Individually shaded boards and vertical battens make timber readable in rotation.
        for row in 0..<30 {
            let y = 4.3 + Float(row) * 0.255
            let style: LandmarkSurface = row % 4 == 0 ? .woodLight : .wood
            box(style, [0, y, 1.67], [3.35, 0.24, 0.12])
            box(style, [0, y, -1.67], [3.35, 0.24, 0.12])
            box(style, [1.67, y, 0], [0.12, 0.24, 3.35])
            box(style, [-1.67, y, 0], [0.12, 0.24, 3.35])
        }
        for x: Float in [-1.75, -1.15, -0.58, 0, 0.58, 1.15, 1.75] {
            box(.woodLight, [x, 8.0, 1.78], [0.08, 7.9, 0.12])
            box(.woodLight, [x, 8.0, -1.78], [0.08, 7.9, 0.12])
            box(.woodLight, [1.78, 8.0, x], [0.12, 7.9, 0.08])
            box(.woodLight, [-1.78, 8.0, x], [0.12, 7.9, 0.08])
        }
        roof(y: 3.95, half: 2.65, rise: 1.0)
        roof(y: 12.0, half: 2.55, rise: 1.15)
        box(.wood, [0, 12.35, 0], [3.65, 0.25, 3.65])
        for x: Float in [-1.48, 1.48] {
            for z: Float in [-1.48, 1.48] {
                box(.woodLight, [x, 14.2, z], [0.22, 3.3, 0.22])
            }
        }
        // Hollow-looking bell with flared lip; a suspended wooden striker beside it.
        lathe(.bronze, profile: [(0.5, 13.5), (0.62, 13.58), (0.53, 13.72),
                                (0.47, 14.5), (0.30, 14.8), (0.06, 14.9), (0, 14.9)])
        box(.wood, [0, 15.05, 0], [0.12, 0.4, 0.12])
        box(.wood, [0.84, 14.1, 0], [0.22, 0.22, 1.7])
        for side in 0..<4 {
            for i in 0...10 {
                let u = -1.55 + Float(i) * 0.31
                if side < 2 { box(.woodLight, [u, 12.95, side == 0 ? 1.6 : -1.6], [0.065, 0.9, 0.065]) }
                else { box(.woodLight, [side == 2 ? 1.6 : -1.6, 12.95, u], [0.065, 0.9, 0.065]) }
            }
        }
        for z: Float in [-1.6, 1.6] { box(.woodLight, [0, 13.4, z], [3.4, 0.12, 0.12]) }
        for x: Float in [-1.6, 1.6] { box(.woodLight, [x, 13.4, 0], [0.12, 0.12, 3.4]) }
        roof(y: 15.8, half: 2.45, rise: 0.85)
        // Square cap at the apex, visible in the supplied frontal photograph.
        box(.roofPatina, [0, 16.83, 0], [0.62, 0.44, 0.62])
    }

    func roof(y: Float, half: Float, rise: Float) {
        let corners: [SIMD2<Float>] = [[-1, 1], [1, 1], [1, -1], [-1, -1]]
        for side in 0..<4 {
            let a = corners[side], b = corners[(side + 1) % 4]
            func p(_ u: Float, _ v: Float) -> SIMD3<Float> {
                let edge = a + (b - a) * u
                let width = half * (1 - v) + 0.23 * v
                let lift = pow(abs(u * 2 - 1), 6) * 0.13 * (1 - v)
                return [edge.x * width, y + rise * pow(v, 0.88) + lift, edge.y * width]
            }
            // Narrow courses with raised seams: the photos show weathered gray-green
            // metal roofing, so avoid coarse, brightly striped "pagoda" wedges.
            for col in 0..<36 {
                let u0 = Float(col) / 36, u1 = Float(col + 1) / 36
                for row in 0..<14 {
                    let v0 = Float(row) / 14, v1 = Float(row + 1) / 14
                    let seam: Float = 0.0012
                    let a0 = p(u0 + seam, v0), b0 = p(u1 - seam, v0)
                    let c0 = p(u1 - seam, v1), d0 = p(u0 + seam, v1)
                    let height = SIMD3<Float>(0, 0.012 + Float(row % 2) * 0.004, 0)
                    face((row + col * 3) % 7 == 0 ? .roofPatina : .copper,
                         a0 + height, b0 + height, c0 + height, d0 + height)
                    face(.bronze, a0, b0, b0 + height, a0 + height)
                    // Standing joints run from the eaves toward the square apex.
                    face(.roofPatina, p(u0, v0), p(u0, v0) + [0, 0.035, 0],
                         p(u0, v1) + [0, 0.035, 0], p(u0, v1))
                }
                let e0 = p(u0, 0), e1 = p(u1, 0)
                face(.copper, e0 - [0, 0.10, 0], e1 - [0, 0.10, 0], e1, e0)
                face(.wood, p(u0, 1), p(u1, 1), e1 - [0, 0.10, 0], e0 - [0, 0.10, 0])
            }
            // Small rafters protruding below the eaves give thickness from below.
            for i in 1..<16 {
                let v = p(Float(i) / 16, 0.04)
                box(.wood, v - [0, 0.13, 0], [0.065, 0.14, 0.15])
            }
        }
        box(.roofPatina, [0, y + rise, 0], [0.5, 0.10, 0.5])
    }

    func museum() {
        // Approximate exterior study from photos and KKAA's published elevations.
        // The projecting lower shell has its own ridges; it is not an extrusion of
        // the sawtooth roof. Coordinates are authored here, not imported survey data.
        let plan: [SIMD2<Float>] = [
            [-5.0,-2.0], [-3.8,-4.5], [2.9,-4.5], [4.9,-2.8],
            [5.1,-1.7], [3.9,-1.4], [5.25,-0.8], [5.3,0.6],
            [4.1,0.85], [5.15,1.4], [4.75,3.0], [3.3,4.5],
            [1.55,4.85], [1.4,3.25], [-0.2,4.55], [-1.8,4.5],
            [-1.95,2.9], [-3.35,4.1], [-4.8,3.65], [-5.2,1.3],
            [-4.35,0.9], [-5.3,0.3], [-5.25,-0.9]
        ]
        let roof = plan.map { SIMD3<Float>($0.x, 7.5, $0.y) }
        let shoulder: [SIMD3<Float>] = [
            [-5.55,3.3,-2.0], [-3.9,4.2,-4.65], [3.35,3.7,-4.8], [5.5,3.1,-3.0],
            [5.8,4.1,-1.65], [4.45,4.1,-1.3], [6.15,5.1,-0.7], [5.65,3.7,0.7],
            [4.6,3.7,0.95], [6.15,5.5,1.5], [5.75,3.1,3.3], [4.6,5.85,5.55],
            [1.6,4.35,5.2], [1.6,4.35,5.2], [-0.05,3.25,4.85], [-1.9,4.6,4.95],
            [-1.9,4.6,4.95], [-3.6,4.65,4.7], [-5.85,5.6,4.85], [-5.65,3.7,1.5],
            [-4.9,3.7,1.15], [-6.15,5.1,0.25], [-5.7,3.4,-1.0]
        ]
        let foot: [SIMD3<Float>] = [
            [-4.65,0,-1.65], [-3.55,0,-3.85], [2.85,0,-3.85], [4.3,0,-2.5],
            [4.4,0,-1.45], [4.4,0,-1.2], [4.5,0,-0.6], [4.45,0,0.6],
            [4.45,0,0.9], [4.4,0,1.4], [4.15,0,2.8], [3.0,0,3.75],
            [1.4,0,3.9], [1.4,0,3.9], [-0.15,0,3.8], [-1.65,0,3.75],
            [-1.65,0,3.75], [-3.1,0,3.6], [-4.6,0,3.25], [-4.6,0,1.4],
            [-4.6,0,1.1], [-4.65,0,0.25], [-4.65,0,-0.8]
        ]
        box(.paving, [0,-0.15,0], [13.8,0.25,11.6])
        var rng = LandmarkRandom(seed: 397259)
        for i in roof.indices {
            let j = (i + 1) % roof.count
            // Front panels are joined around low ridge vertices below, rather
            // than the horizontal belt used on the other elevations.
            if !(11...13).contains(i) && !(15...17).contains(i) {
                museumWall(foot[i], foot[j], shoulder[j], shoulder[i],
                           opening: i == 14 ? .slit : (i == 9 ? .entrance : .none), rng: &rng)
            }
            museumWall(shoulder[i], shoulder[j], roof[j], roof[i], rng: &rng)
            let innerA = SIMD3<Float>(roof[i].x * 0.985,7.5,roof[i].z * 0.985)
            let innerB = SIMD3<Float>(roof[j].x * 0.985,7.5,roof[j].z * 0.985)
            face(.stone, roof[j],roof[i],innerA,innerB)
            face(.concrete,innerB,innerA,[innerA.x,7.18,innerA.z],[innerB.x,7.18,innerB.z])
        }
        // Large triangular planes meet near the ground. The outer upper corners
        // project in front of the upper walls, with a sloping face back to the roof.
        // Their silhouette and depth remain visible when the model is rotated.
        func foldedFront(_ rim: [SIMD3<Float>], ridge: SIMD3<Float>, entrance: Bool = false) {
            for i in rim.indices {
                if entrance && i == 0 {
                    museumWall(rim[0], rim[1], ridge, ridge, opening: .entrance, rng: &rng)
                } else {
                    museumStoneTriangle(rim[i], ridge, rim[(i + 1) % rim.count], rng: &rng)
                }
            }
        }
        foldedFront([foot[11], foot[14], shoulder[14], shoulder[12], shoulder[11]],
                    ridge: [0.4, 1.25, 5.1])
        foldedFront([foot[15], foot[18], shoulder[18], shoulder[17], shoulder[15]],
                    ridge: [-2.1, 1.7, 5.05], entrance: true)
        flatRoof(plan.reversed().map { $0 * 0.985 }, y: 7.18, style: .concrete)
        // The aerial photo resolves the previously unknown roof: shallow parapet,
        // pale service roof, equipment boxes and an open steel-framed service zone.
        box(.darkGlass,[1.45,7.20,-1.65],[3.65,0.035,3.45])
        for x: Float in [-0.4,1.45,3.3] {
            box(.concrete,[x,7.37,-1.65],[0.09,0.18,3.5])
        }
        for z: Float in [-3.4,-1.65,0.1] {
            box(.concrete,[1.45,7.37,z],[3.8,0.18,0.09])
        }
        func beam(_ a: SIMD3<Float>, _ b: SIMD3<Float>) {
            let direction = simd_normalize(b-a)
            let side = simd_normalize(simd_cross(direction,SIMD3<Float>(0,1,0))) * 0.045
            let up = SIMD3<Float>(0,0.045,0)
            face(.concrete,a-side-up,b-side-up,b-side+up,a-side+up)
            face(.concrete,b+side-up,a+side-up,a+side+up,b+side+up)
            face(.concrete,a-side+up,b-side+up,b+side+up,a+side+up)
        }
        for x: Float in [-0.4,1.45] {
            for z: Float in [-3.4,-1.65] {
                beam([x,7.45,z],[x+1.85,7.45,z+1.75])
                beam([x+1.85,7.45,z],[x,7.45,z+1.75])
            }
        }
        for (x,z,w,d): (Float,Float,Float,Float) in [(-2.9,-1.8,0.9,0.65),(-2.3,-0.6,0.8,0.6),(-2.8,1.0,0.65,0.9)] {
            box(.concrete,[x,7.48,z],[w,0.6,d])
            box(.trim,[x,7.79,z],[w*0.94,0.035,d*0.94])
        }
    }

    private enum MuseumOpening { case none, slit, entrance }

    /// A real hole with stone reveals and a recessed back. The dark opening is
    /// geometry within the wall, not a stripe laid over the masonry.
    private func museumWall(_ a: SIMD3<Float>, _ b: SIMD3<Float>, _ c: SIMD3<Float>, _ d: SIMD3<Float>,
                            opening: MuseumOpening = .none, rng: inout LandmarkRandom) {
        func tile(_ a: SIMD3<Float>,_ b: SIMD3<Float>,_ c: SIMD3<Float>,_ d: SIMD3<Float>) {
            museumStoneTriangle(a,c,b,rng:&rng)
            museumStoneTriangle(a,d,c,rng:&rng)
        }
        guard opening != .none else { tile(a,b,c,d); return }
        func p(_ u: Float,_ v: Float) -> SIMD3<Float> {
            // Piecewise affine interpolation matches the two wall triangles.
            if u >= v { return a + (b-a)*(u-v) + (c-a)*v }
            return a + (c-a)*u + (d-a)*(v-u)
        }
        let u0: Float = opening == .slit ? 0.27 : 0.34
        let u1: Float = opening == .slit ? 0.55 : 0.79
        let v0: Float = opening == .slit ? 0.16 : 0
        let v1: Float = opening == .slit ? 0.97 : 0.28
        let us: [Float] = [0,u0,u1,1], vs: [Float] = [0,v0,v1,1]
        for row in 0..<3 { for col in 0..<3 where !(row == 1 && col == 1) {
            guard vs[row+1] > vs[row] else { continue }
            tile(p(us[col],vs[row]),p(us[col+1],vs[row]),p(us[col+1],vs[row+1]),p(us[col],vs[row+1]))
        }}
        let outer = [p(u0,v0),p(u1,v0),p(u1,v1),p(u0,v1)]
        let inward = simd_normalize(simd_cross(b-a,d-a)) * (opening == .slit ? 0.85 : 1.0)
        let inner = outer.map { $0 + inward }
        face(.darkGlass,inner[3],inner[2],inner[1],inner[0])
        face(.darkGlass,inner[0],inner[1],inner[2],inner[3])
        for i in 0..<4 {
            let j = (i+1)%4
            tile(outer[i],inner[i],inner[j],outer[j])
            tile(outer[j],inner[j],inner[i],outer[i])
        }
    }

    /// Clip small stone courses to a planar triangle. All vertices stay on that
    /// plane (plus shallow relief), including tiles crossing the facet boundary.
    func museumStoneTriangle(_ a: SIMD3<Float>, _ b: SIMD3<Float>, _ c: SIMD3<Float>,
                             rng: inout LandmarkRandom) {
        let cross = simd_cross(b - a, c - a)
        guard simd_length_squared(cross) > 0.000001 else { return }
        let n = simd_normalize(cross)
        let horizontal = simd_cross(SIMD3<Float>(0,1,0),n)
        let x = simd_length_squared(horizontal) > 0.001 ? simd_normalize(horizontal) : simd_normalize(b-a)
        let y = simd_cross(n,x)
        let triangle = [SIMD2<Float>.zero,
                        SIMD2<Float>(simd_dot(b-a,x),simd_dot(b-a,y)),
                        SIMD2<Float>(simd_dot(c - a, x), simd_dot(c - a, y))]
        func side(_ a: SIMD2<Float>, _ b: SIMD2<Float>, _ p: SIMD2<Float>) -> Float {
            (b.x - a.x) * (p.y - a.y) - (b.y - a.y) * (p.x - a.x)
        }
        face(.stoneDark, a, b, c, c)
        let minX = triangle.map(\.x).min()!, maxX = triangle.map(\.x).max()!
        let minY = triangle.map(\.y).min()!, maxY = triangle.map(\.y).max()!
        for row in Int(floor(minY / 0.115))...Int(ceil(maxY / 0.115)) {
            for col in Int(floor(minX / 0.22))...Int(ceil(maxX / 0.22)) {
                let left = Float(col) * 0.22 + (row % 2 == 0 ? 0 : 0.11)
                let bottom = Float(row) * 0.115
                var polygon: [SIMD2<Float>] = [[left + 0.004, bottom + 0.004],
                    [left + 0.216, bottom + 0.004], [left + 0.216, bottom + 0.111],
                    [left + 0.004, bottom + 0.111]]
                for edge in 0..<3 {
                    let start = triangle[edge], end = triangle[(edge + 1) % 3]
                    var clipped: [SIMD2<Float>] = []
                    guard !polygon.isEmpty else { break }
                    for index in polygon.indices {
                        let p = polygon[index], q = polygon[(index + 1) % polygon.count]
                        let dp = side(start, end, p), dq = side(start, end, q)
                        if dp >= 0 { clipped.append(p) }
                        if (dp >= 0) != (dq >= 0) { clipped.append(p + (q - p) * (dp / (dp - dq))) }
                    }
                    polygon = clipped
                }
                guard polygon.count >= 3 else { continue }
                let depth = Float(0.006) + rng.next() * 0.01
                let shade = rng.next()
                let style: LandmarkSurface = shade < 0.12 ? .stoneDark : (shade > 0.88 ? .stoneLight : .stone)
                let vertices = polygon.map { a + x * $0.x + y * $0.y + n * depth }
                for k in 1..<(vertices.count - 1) {
                    face(style, vertices[0], vertices[k], vertices[k + 1], vertices[k + 1])
                }
            }
        }
    }

    func flatRoof(_ outline: [SIMD2<Float>], y: Float, style: LandmarkSurface = .trim) {
        var remaining = Array(outline.indices)
        func cross(_ a: SIMD2<Float>, _ b: SIMD2<Float>, _ c: SIMD2<Float>) -> Float {
            let u = b - a, v = c - a
            return u.x * v.y - u.y * v.x
        }
        while remaining.count > 2 {
            var clipped = false
            for k in remaining.indices {
                let ia = remaining[(k + remaining.count - 1) % remaining.count]
                let ib = remaining[k], ic = remaining[(k + 1) % remaining.count]
                let a = outline[ia], b = outline[ib], c = outline[ic]
                guard cross(a, b, c) < -0.0001 else { continue }
                let contains = remaining.contains { index in
                    guard index != ia && index != ib && index != ic else { return false }
                    let p = outline[index]
                    return cross(a, b, p) <= 0 && cross(b, c, p) <= 0 && cross(c, a, p) <= 0
                }
                guard !contains else { continue }
                let p0 = SIMD3<Float>(a.x, y, a.y)
                let p1 = SIMD3<Float>(b.x, y, b.y)
                let p2 = SIMD3<Float>(c.x, y, c.y)
                face(style, p0, p1, p2, p2)
                remaining.remove(at: k)
                clipped = true
                break
            }
            guard clipped else { break }
        }
    }

    /// Batched shallow stone relief, not a flat photograph. Deterministic for every launch.
    func stoneFace(_ a: SIMD3<Float>, _ b: SIMD3<Float>, _ c: SIMD3<Float>, _ d: SIMD3<Float>,
                   columns: Int, rows: Int, slits: Bool = false, rng: inout LandmarkRandom) {
        let normal = simd_normalize(simd_cross(b - a, d - a))
        func point(_ u: Float, _ v: Float) -> SIMD3<Float> {
            (a + (b - a) * u) * (1 - v) + (d + (c - d) * u) * v
        }
        for row in 0..<rows {
            for col in 0...columns {
                let inset: Float = 0.055
                let shift: Float = row % 2 == 0 ? 0 : 0.5
                let u0 = max(0, (Float(col) - shift + inset) / Float(columns))
                let u1 = min(1, (Float(col + 1) - shift - inset) / Float(columns))
                guard u1 > u0 else { continue }
                if slits && row > rows / 2 && (col == 4 || col == 11) {
                    let recess = normal * -0.22
                    face(.darkGlass, point(u0, Float(row) / Float(rows)) + recess,
                         point(u1, Float(row) / Float(rows)) + recess,
                         point(u1, Float(row + 1) / Float(rows)) + recess,
                         point(u0, Float(row + 1) / Float(rows)) + recess)
                    continue
                }
                let v0 = (Float(row) + inset) / Float(rows)
                let v1 = (Float(row + 1) - inset) / Float(rows)
                let relief = normal * (0.008 + rng.next() * 0.018)
                let shade = rng.next()
                let style: LandmarkSurface = shade < 0.23 ? .stoneDark : (shade > 0.78 ? .stoneLight : .stone)
                let p0 = point(u0, v0), p1 = point(u1, v0), p2 = point(u1, v1), p3 = point(u0, v1)
                face(style, p0 + relief, p1 + relief, p2 + relief, p3 + relief)
                face(.stoneDark, p0, p1, p1 + relief, p0 + relief)
                face(.stoneDark, p1, p2, p2 + relief, p1 + relief)
                face(.stoneDark, p2, p3, p3 + relief, p2 + relief)
                face(.stoneDark, p3, p0, p0 + relief, p3 + relief)
            }
        }
        let backing = normal * -0.26
        face(.stoneDark, a + backing, b + backing, c + backing, d + backing)
    }
}
