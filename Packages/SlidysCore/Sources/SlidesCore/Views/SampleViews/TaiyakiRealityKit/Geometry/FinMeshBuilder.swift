import Foundation
import simd

/// A curved, closed lens with a thin perimeter; used by the two fins and tail.
struct TaiyakiFinSurface: Sendable {
    let contour: [SIMD2<Float>]
    let center: SIMD2<Float>
    let thickness: Float
    let curve: Float

    func height(_ p: SIMD2<Float>, side: Float) -> Float {
        let delta = p - center
        let d = simd_length(delta) < 0.00001 ? SIMD2<Float>(1, 0) : simd_normalize(delta)
        let radius = TaiyakiCurves.radius(from: center, direction: d, contour: contour)
        let r = min(1, simd_length(delta) / radius)
        return curve * (p.x - center.x) * 3 + side * thickness * 0.5 * sqrt(max(0, 1 - r * r))
    }

    func point(_ p: SIMD2<Float>, side: Float) -> SIMD3<Float> {
        [p.x, p.y, height(p, side: side)]
    }
}

enum FinMeshBuilder {
    static func dorsal(_ c: TaiyakiConfiguration) -> TaiyakiFinSurface {
        make(contour: TaiyakiDesign.dorsalContour, center: TaiyakiDesign.dorsalCenter,
             c: c, thickness: c.tailThickness * 0.85)
    }

    static func ventral(_ c: TaiyakiConfiguration) -> TaiyakiFinSurface {
        make(contour: TaiyakiDesign.ventralContour, center: TaiyakiDesign.ventralCenter,
             c: c, thickness: c.tailThickness * 0.8)
    }

    private static func make(contour: [SIMD2<Float>], center: SIMD2<Float>, c: TaiyakiConfiguration,
                             thickness: Float) -> TaiyakiFinSurface {
        let yScale = c.bodyHeight / 0.67
        let transformed = contour.map { p in
            let v = center + (p - center) * c.finSize
            return SIMD2<Float>(v.x, v.y * yScale)
        }
        return TaiyakiFinSurface(contour: TaiyakiCurves.spline(transformed, closed: true),
                                 center: [center.x, center.y * yScale], thickness: thickness, curve: 0)
    }

    static func build(_ surface: TaiyakiFinSurface, segments: Int = 96, rings: Int = 10) -> TaiyakiMesh {
        var mesh = TaiyakiMesh()
        var perimeter: [UInt32] = []
        for side: Float in [1, -1] {
            let center = mesh.vertex(surface.point(surface.center, side: side))
            var previous: [UInt32] = []
            for ring in 1...rings {
                let t = sin(Float(ring) / Float(rings) * .pi / 2)
                var current: [UInt32] = []
                for i in 0..<segments {
                    let angle = Float(i) / Float(segments) * 2 * .pi
                    let d = SIMD2<Float>(cos(angle), sin(angle))
                    let r = TaiyakiCurves.radius(from: surface.center, direction: d, contour: surface.contour)
                    let p = surface.center + d * r * t
                    current.append(side < 0 && ring == rings ? perimeter[i] : mesh.vertex(surface.point(p, side: side)))
                }
                for i in 0..<segments {
                    let j = (i + 1) % segments
                    if ring == 1 { mesh.triangle(center, current[i], current[j], reversed: side < 0) }
                    else { mesh.quad(previous[i], current[i], current[j], previous[j], reversed: side < 0) }
                }
                if side > 0 && ring == rings { perimeter = current }
                previous = current
            }
        }
        return mesh
    }
}

