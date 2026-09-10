import simd

enum TailMeshBuilder {
    static func surface(_ c: TaiyakiConfiguration) -> TaiyakiFinSurface {
        func transform(_ p: SIMD2<Float>) -> SIMD2<Float> {
            [0.40 + (p.x - 0.40) * c.tailWidth / 0.34, p.y * c.tailHeight / 0.55]
        }
        return TaiyakiFinSurface(
            contour: TaiyakiCurves.spline(TaiyakiDesign.tailContour.map(transform), closed: true),
            center: transform(TaiyakiDesign.tailCenter), thickness: c.tailThickness, curve: c.tailCurve)
    }

    static func build(_ c: TaiyakiConfiguration) -> TaiyakiMesh {
        FinMeshBuilder.build(surface(c))
    }
}

