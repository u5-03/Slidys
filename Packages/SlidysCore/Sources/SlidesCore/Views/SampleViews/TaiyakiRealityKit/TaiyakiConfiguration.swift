import Foundation

/// Lengths other than bodyLength are ratios of bodyLength. The reference is viewed
/// with its head on the left, Y up, and the cut/filling facing +Z.
struct TaiyakiConfiguration: Sendable, Equatable {
    var bodyLength: Float = 0.30
    var bodyHeight: Float = 0.67
    var bodyThickness: Float = 0.205
    var headScale: Float = 1.08
    var headBulge: Float = 0.20
    var bellyBulge: Float = 0.14
    /// Lower values retain a broader crown before rounding into the perimeter.
    var bodyCrown: Float = 0.44
    var tailTaper: Float = 0.46
    var edgeThickness: Float = 0.028
    var tailWidth: Float = 0.34
    var tailHeight: Float = 0.55
    var tailThickness: Float = 0.078
    var tailCurve: Float = 0.010
    var finSize: Float = 1
    var mouthOpening: Float = 0.17
    var fillingAmount: Float = 1
    var eyeSize: Float = 0.060
    var faceLineWidth: Float = 0.030
    var scaleDensity: Int = 2
    var scaleDepth: Float = 0.0016
    var scaleWidth: Float = 0.021
    var browningAmount: Float = 0.42
    var contourSegments: Int = 160
    var bodyRings: Int = 24
    var textureResolution: Int = 512
    var seed: UInt64 = 0x5355474959

    /// Keep caller-provided values in the region where the cut stays inside the shell.
    var validated: Self {
        var c = self
        func clamp(_ value: Float, _ lower: Float, _ upper: Float) -> Float {
            value.isFinite ? min(upper, max(lower, value)) : lower
        }
        c.bodyLength = clamp(bodyLength, 0.05, 2)
        c.bodyHeight = clamp(bodyHeight, 0.58, 0.80)
        c.bodyThickness = clamp(bodyThickness, 0.10, 0.32)
        c.headScale = clamp(headScale, 0.92, 1.10)
        c.headBulge = clamp(headBulge, 0, 0.35)
        c.bellyBulge = clamp(bellyBulge, 0, 0.25)
        c.bodyCrown = clamp(bodyCrown, 0.35, 0.75)
        c.tailTaper = clamp(tailTaper, 0.20, 0.65)
        c.edgeThickness = clamp(edgeThickness, 0.01, 0.05)
        c.tailWidth = clamp(tailWidth, 0.24, 0.44)
        c.tailHeight = clamp(tailHeight, 0.40, 0.65)
        c.tailThickness = clamp(tailThickness, 0.04, 0.12)
        c.tailCurve = clamp(tailCurve, -0.04, 0.04)
        c.finSize = clamp(finSize, 0.7, 1.25)
        c.mouthOpening = clamp(mouthOpening, 0.10, 0.20)
        c.fillingAmount = clamp(fillingAmount, 0.4, 1.3)
        c.eyeSize = clamp(eyeSize, 0.02, 0.08)
        c.faceLineWidth = clamp(faceLineWidth, 0.018, 0.040)
        c.scaleDensity = min(4, max(1, scaleDensity))
        c.scaleDepth = clamp(scaleDepth, 0.0005, 0.004)
        c.scaleWidth = clamp(scaleWidth, 0.012, 0.028)
        c.browningAmount = clamp(browningAmount, 0, 1)
        c.contourSegments = min(240, max(64, contourSegments))
        c.bodyRings = min(36, max(12, bodyRings))
        c.textureResolution = min(1024, max(128, textureResolution))
        return c
    }
}

/// Artistic landmarks are kept together rather than scattered through builders.
enum TaiyakiDesign {
    static let bodyCenter = SIMD2<Float>(-0.06, -0.015)
    static let cutCenter = SIMD2<Float>(0.105, -0.005)
    static let cutHalfHeight: Float = 0.274
    static let crumbWidth: Float = 0.018
    static let cutDepth: Float = 0.038
    static let eye = SIMD2<Float>(-0.343, 0.034)
    // Landmarks follow the original icon, rotated to point left. The eye sits
    // beneath a widening triangular lid, not beneath a separate eyebrow bar.
    static let eyelidContour: [SIMD2<Float>] = [
        [-0.404, 0.045], [-0.392, 0.054], [-0.286, 0.142],
        [-0.276, 0.145], [-0.250, 0.108], [-0.255, 0.098],
        [-0.390, 0.039]
    ].reversed()
    static let facePaths: [[SIMD2<Float>]] = [
        [[-0.425, -0.122], [-0.331, -0.127], [-0.268, -0.147],
         [-0.263, -0.168], [-0.310, -0.194], [-0.414, -0.207]],
        [[-0.209, 0.092], [-0.180, 0.065], [-0.143, -0.006],
         [-0.115, -0.092], [-0.113, -0.168], [-0.126, -0.218], [-0.145, -0.238]],
        [[-0.116, -0.089], [-0.074, -0.070], [-0.024, -0.052]],
        [[-0.111, -0.143], [-0.057, -0.128], [0.004, -0.127]],
        [[-0.118, -0.201], [-0.051, -0.207], [0.016, -0.204]],
        [[-0.173, 0.250], [-0.153, 0.220], [-0.122, 0.193],
         [-0.104, 0.159], [-0.107, 0.145], [-0.083, 0.116],
         [-0.057, 0.096], [-0.070, 0.059]]
    ]
    static let lineWidth: Float = 0.010
    // (X, top Y, bottom Y). Interpolating within these ranges keeps every
    // scalloped column inside the mold border, even when density is increased.
    static let frontScaleStart = SIMD3<Float>(0.235, 0.205, -0.160)
    static let frontScaleEnd = SIMD3<Float>(0.305, 0.126, -0.120)
    static let backScaleStart = SIMD3<Float>(0.030, 0.251, -0.235)
    static let backScaleEnd = SIMD3<Float>(0.305, 0.126, -0.120)
    static let cutScallop: Float = 0.022
    static let cutFineScallop: Float = 0.010
    static let scaleArcWidth: Float = 0.034
    static let patternCurveSubdivisions = 14
    static let patternCrossSections = 16
    static let patternSeating: Float = 0.35
    static let patternNormalClearance: Float = 0.5
    static let logoOrigin = SIMD2<Float>(0.172, -0.228)
    static let logoScale = SIMD2<Float>(0.073, 0.069)
    static let logoSlope: Float = 0.26
    // Counter-clockwise, beginning at the upper lip. These are deliberately
    // asymmetric: a broad forehead, rounded belly, and small caudal peduncle.
    static let bodyContour: [SIMD2<Float>] = [
        [-0.505, -0.175], [-0.480, -0.100], [-0.451, 0.035],
        [-0.380, 0.169], [-0.265, 0.265], [-0.125, 0.320],
        [0.035, 0.325], [0.190, 0.285], [0.320, 0.215],
        [0.415, 0.110], [0.465, 0.010], [0.445, -0.115],
        [0.340, -0.240], [0.185, -0.315], [0.010, -0.344],
        [-0.175, -0.335], [-0.340, -0.303], [-0.468, -0.243],
        [-0.517, -0.207]
    ].reversed()
    static let tailCenter = SIMD2<Float>(0.56, -0.022)
    static let tailContour: [SIMD2<Float>] = [
        [0.380, 0.100], [0.495, 0.185], [0.705, 0.285],
        [0.748, 0.272], [0.752, 0.182], [0.710, -0.002],
        [0.746, -0.207], [0.728, -0.260], [0.607, -0.273],
        [0.460, -0.190], [0.375, -0.117]
    ].reversed()
    static let dorsalCenter = SIMD2<Float>(0.11, 0.307)
    static let dorsalContour: [SIMD2<Float>] = [
        [-0.150, 0.264], [-0.052, 0.364], [0.063, 0.470],
        [0.121, 0.481], [0.207, 0.441], [0.323, 0.348],
        [0.360, 0.189], [0.171, 0.245]
    ].reversed()
    static let ventralCenter = SIMD2<Float>(0.14, -0.285)
    static let ventralContour: [SIMD2<Float>] = [
        [-0.015, -0.270], [0.056, -0.380], [0.128, -0.412],
        [0.242, -0.349], [0.339, -0.229], [0.158, -0.247]
    ]
}
