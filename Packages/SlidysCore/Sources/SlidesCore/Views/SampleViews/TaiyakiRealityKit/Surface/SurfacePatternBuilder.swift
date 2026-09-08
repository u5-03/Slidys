import Foundation
import simd

enum SurfacePatternBuilder {
    struct Result: Sendable {
        var mold = TaiyakiMesh()
        var eyes = TaiyakiMesh()
        var logo = TaiyakiMesh()
    }

    static func build(surface: TaiyakiBodySurface, bodyMesh: TaiyakiMesh? = nil) -> Result {
        let c = surface.configuration
        let projection = TaiyakiBodyProjection(mesh: bodyMesh ?? BodyMeshBuilder.build(surface: surface), surface: surface)
        var result = Result()
        // Deliberately sparse, broad mold marks matching the icon's graphic language.
        let face = TaiyakiDesign.facePaths
        for side: Float in [1, -1] {
            let bodyPoint: (SIMD2<Float>) -> SIMD3<Float> = {
                projection.point($0, side: side)
                    + surface.normal($0, side: side) * c.scaleDepth * TaiyakiDesign.patternNormalClearance
            }
            for path in face {
                result.mold.append(stroke(path.map { scaled($0, c) }, width: c.faceLineWidth,
                                          depth: c.scaleDepth, side: side, curvedEdge: true, project: bodyPoint))
            }
            // In the back view the uninterrupted center continues the scale motif.
            let columns = side > 0 ? c.scaleDensity : c.scaleDensity + 1
            for column in 0..<columns {
                let start = side > 0 ? TaiyakiDesign.frontScaleStart : TaiyakiDesign.backScaleStart
                let end = side > 0 ? TaiyakiDesign.frontScaleEnd : TaiyakiDesign.backScaleEnd
                let t = Float(column) / Float(max(1, columns - 1))
                let layout = start * (1 - t) + end * t
                let arc = TaiyakiDesign.scaleArcWidth
                // Two joined rounded scallops, matching the sparse icon motif.
                let path: [SIMD2<Float>] = [[0, 1], [0.78, 0.93], [1, 0.75],
                    [0.70, 0.59], [0, 0.50], [0.70, 0.41], [1, 0.25],
                    [0.78, 0.07], [0, 0]]
                let positioned = path.map { scaled([layout.x + $0.x * arc,
                                                   layout.z + $0.y * (layout.y - layout.z)], c) }
                result.mold.append(stroke(positioned, width: c.scaleWidth,
                                          depth: c.scaleDepth, side: side, project: bodyPoint))
            }
            let seam: [SIMD2<Float>] = [[0.078, 0.307], [0.233, 0.240], [0.343, 0.136],
                [0.393, 0.008], [0.355, -0.141], [0.218, -0.260], [0.081, -0.311]]
            // The upper end terminates outside the cut instead of crossing it.
            let seamTrimmed = Array(seam.dropFirst())
            result.mold.append(stroke(seamTrimmed.map { scaled($0, c) }, width: 0.020,
                                      depth: c.scaleDepth, side: side, project: bodyPoint))

            let eyeContour = (0..<48).map { i -> SIMD2<Float> in
                let angle = Float(i) / 48 * 2 * .pi
                return scaled(TaiyakiDesign.eye + SIMD2<Float>(cos(angle), sin(angle)) * c.eyeSize * 0.56, c)
            }
            result.eyes.append(stamp(eyeContour, depth: c.scaleDepth * 0.6,
                                     side: side, project: bodyPoint))
            let lid = TaiyakiCurves.spline(TaiyakiDesign.eyelidContour.map { scaled($0, c) }, closed: true)
            result.mold.append(stamp(lid, depth: c.scaleDepth * 1.4, side: side, project: bodyPoint))
            appendFinMarks(to: &result.mold, configuration: c, side: side)
        }
        result.logo = logo(surface: surface, projection: projection)
        return result
    }

    private static func scaled(_ p: SIMD2<Float>, _ c: TaiyakiConfiguration) -> SIMD2<Float> {
        let headWeight = max(0, min(1, -p.x / 0.30))
        return [p.x, p.y * c.bodyHeight / 0.67 * (1 + (c.headScale - 1) * headWeight)]
    }

    /// A shallow closed stamp follows the shell, retaining the graphic silhouette
    /// of the round eye and triangular lid when the fish is seen from the front.
    private static func stamp(_ contour: [SIMD2<Float>], depth: Float, side: Float,
                              project: (SIMD2<Float>) -> SIMD3<Float>) -> TaiyakiMesh {
        let center = contour.reduce(.zero, +) / Float(contour.count)
        let rings = 8, count = contour.count
        var mesh = TaiyakiMesh()
        var edge: [UInt32] = []
        for face: Float in [1, -1] {
            func point(_ p: SIMD2<Float>, radius: Float) -> SIMD3<Float> {
                var v = project(p)
                v.z += side * face * depth * (1 - pow(radius, 8))
                return v
            }
            let pole = mesh.vertex(point(center, radius: 0))
            var previous: [UInt32] = []
            for ring in 1...rings {
                let t = Float(ring) / Float(rings)
                let current = contour.indices.map { i in
                    face < 0 && ring == rings ? edge[i]
                        : mesh.vertex(point(center * (1 - t) + contour[i] * t, radius: t))
                }
                for i in 0..<count {
                    let j = (i + 1) % count
                    if ring == 1 { mesh.triangle(pole, current[i], current[j], reversed: side * face < 0) }
                    else { mesh.quad(previous[i], current[i], current[j], previous[j], reversed: side * face < 0) }
                }
                if face > 0 && ring == rings { edge = current }
                previous = current
            }
        }
        return mesh
    }

    private static func appendFinMarks(to mesh: inout TaiyakiMesh, configuration c: TaiyakiConfiguration, side: Float) {
        let dorsal = FinMeshBuilder.dorsal(c), ventral = FinMeshBuilder.ventral(c)
        for (surface, marks) in [
            (dorsal, [[SIMD2<Float>(0.008, 0.338), [0.043, 0.419]],
                      [[0.103, 0.315], [0.151, 0.391]], [[0.202, 0.289], [0.252, 0.344]]]),
            (ventral, [[SIMD2<Float>(0.098, -0.315), [0.120, -0.367]],
                       [[0.189, -0.287], [0.207, -0.329]]])
        ] {
            for mark in marks {
                let originalCenter = surface.center / SIMD2<Float>(1, c.bodyHeight / 0.67)
                let path = mark.map { originalCenter + ($0 - originalCenter) * c.finSize }
                    .map { SIMD2<Float>($0.x, $0.y * c.bodyHeight / 0.67) }
                mesh.append(stroke(path, width: 0.019, depth: c.scaleDepth, side: side,
                                   project: { surface.point($0, side: side) }))
            }
        }
        let tail = TailMeshBuilder.surface(c)
        let tailMarks: [[SIMD2<Float>]] = [
            [[0.415, 0.066], [0.532, 0.124], [0.687, 0.211]],
            [[0.425, -0.010], [0.550, -0.010], [0.681, 0.002]],
            [[0.421, -0.082], [0.525, -0.137], [0.680, -0.206]]
        ]
        for mark in tailMarks {
            let path = mark.map { SIMD2<Float>(0.40 + ($0.x - 0.40) * c.tailWidth / 0.34, $0.y * c.tailHeight / 0.55) }
            mesh.append(stroke(path, width: 0.022, depth: c.scaleDepth, side: side,
                               project: { tail.point($0, side: side) }))
        }
    }

    /// Flattened round strokes with closed, rounded ends. All vertices are
    /// projected individually, allowing the marks to follow curved pastry.
    static func stroke(_ control: [SIMD2<Float>], width: Float, depth: Float, side: Float, curvedEdge: Bool = false,
                       project: (SIMD2<Float>) -> SIMD3<Float>) -> TaiyakiMesh {
        let points = TaiyakiCurves.spline(control, subdivisions: curvedEdge ? TaiyakiDesign.patternCurveSubdivisions : 7)
        guard points.count > 1 else { return TaiyakiMesh() }
        var mesh = TaiyakiMesh()
        let segments = curvedEdge ? TaiyakiDesign.patternCrossSections : 10
        let firstTangent = simd_normalize(points[1] - points[0])
        let lastTangent = simd_normalize(points[points.count - 1] - points[points.count - 2])
        let capAngles: [Float] = [0.15, .pi / 6, .pi / 3]
        let startCap = capAngles.map { points[0] - firstTangent * width * 0.5 * cos($0) }
        let endCap = capAngles.reversed().map { points.last! + lastTangent * width * 0.5 * cos($0) }
        let extended = startCap + points + endCap
        let factors = capAngles.map { sin($0) } + Array(repeating: Float(1), count: points.count)
            + capAngles.reversed().map { sin($0) }
        for i in extended.indices {
            let p = extended[i]
            let tangent = simd_normalize(extended[min(i + 1, extended.count - 1)] - extended[max(i - 1, 0)])
            let normal = SIMD2<Float>(-tangent.y, tangent.x)
            let factor = factors[i]
            for j in 0..<segments {
                let angle = Float(j) / Float(segments) * 2 * .pi
                let xy = p + normal * cos(angle) * width * 0.5 * factor
                var v = project(xy)
                v.z += side * (sin(angle) * depth * factor + depth * TaiyakiDesign.patternSeating)
                mesh.vertex(v)
            }
        }
        for i in 0..<(extended.count - 1) {
            for j in 0..<segments {
                let k = (j + 1) % segments
                mesh.quad(UInt32(i * segments + j), UInt32(i * segments + k),
                          UInt32((i + 1) * segments + k), UInt32((i + 1) * segments + j), reversed: side < 0)
            }
        }
        let start = mesh.vertex(project(extended[0]))
        let end = mesh.vertex(project(extended.last!))
        for j in 0..<segments {
            let k = (j + 1) % segments
            mesh.triangle(start, UInt32(k), UInt32(j), reversed: side < 0)
            let offset = UInt32((extended.count - 1) * segments)
            mesh.triangle(end, offset + UInt32(j), offset + UInt32(k), reversed: side < 0)
        }
        return mesh
    }

    private static func logo(surface: TaiyakiBodySurface, projection: TaiyakiBodyProjection) -> TaiyakiMesh {
        // Clear the complete mold relief, including its seating offset. Moving
        // along the surface normal preserves the curved stamp at oblique angles.
        let lift = surface.configuration.scaleDepth
            * (1 + TaiyakiDesign.patternSeating + TaiyakiDesign.patternNormalClearance)
            + TaiyakiDesign.logoDepth + TaiyakiDesign.logoClearance
        // Handwritten single-line glyphs avoid font or image assets. The descenders
        // are retained, while every stroke conforms to the pastry surface.
        let glyphs: [[[SIMD2<Float>]]] = [
            [[[0.65, 0.86], [0.45, 1], [0.12, 0.82], [0.12, 0.62], [0.48, 0.43],
              [0.57, 0.22], [0.30, 0.02], [0.03, 0.11], [0.02, 0.27]]],
            [[[0.12, 0.63], [0.03, 0.15], [0.13, 0.02], [0.36, 0.15], [0.53, 0.65],
              [0.41, 0.10], [0.54, 0.04], [0.69, 0.19]]],
            [[[0.51, 0.53], [0.36, 0.66], [0.10, 0.42], [0.09, 0.12], [0.29, 0.08],
              [0.48, 0.47], [0.34, -0.34], [0.17, -0.48], [-0.03, -0.36], [0.09, -0.22], [0.68, 0.19]]],
            [[[0.19, 0.57], [0.10, 0.11], [0.22, 0.05], [0.38, 0.19]], [[0.22, 0.85], [0.24, 0.88]]],
            [[[0.05, 0.60], [0.04, 0.18], [0.18, 0.09], [0.47, 0.55], [0.34, -0.25],
              [0.14, -0.49], [-0.04, -0.41], [0.02, -0.24], [0.60, 0.23]]]
        ]
        var mesh = TaiyakiMesh()
        let advances: [Float] = [0.69, 0.65, 0.67, 0.34, 0.62]
        var x: Float = 0
        for (i, glyph) in glyphs.enumerated() {
            for path in glyph {
                let transformed = path.map { p -> SIMD2<Float> in
                    let u = (p.x + x) * TaiyakiDesign.logoScale.x
                    return [TaiyakiDesign.logoOrigin.x + u,
                            (TaiyakiDesign.logoOrigin.y + p.y * TaiyakiDesign.logoScale.y
                             + u * TaiyakiDesign.logoSlope) * surface.configuration.bodyHeight / 0.67]
                }
                mesh.append(stroke(transformed, width: TaiyakiDesign.logoStrokeWidth, depth: TaiyakiDesign.logoDepth, side: 1,
                                   project: { projection.point($0, side: 1)
                    + surface.normal($0, side: 1) * lift }))
            }
            x += advances[i]
        }
        return mesh
    }
}
