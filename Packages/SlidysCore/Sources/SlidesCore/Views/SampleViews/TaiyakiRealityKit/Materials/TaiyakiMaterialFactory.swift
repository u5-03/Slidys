import CoreGraphics
import Foundation
import RealityKit
#if canImport(UIKit)
import UIKit
private typealias TaiyakiColor = UIColor
#else
import AppKit
private typealias TaiyakiColor = NSColor
#endif

enum TaiyakiMaterialFactory {
    struct TexturePixels: Sendable {
        let color: [UInt8]
        let normal: [UInt8]
        let size: Int
    }

    /// Deterministic value noise, computed once off the main actor, with no image
    /// files or shaders. Low-contrast grain preserves the icon's soft appearance.
    static func pixels(surface: TaiyakiBodySurface) -> TexturePixels {
        let c = surface.configuration, size = c.textureResolution
        var colors = [UInt8](), normals = [UInt8]()
        colors.reserveCapacity(size * size * 4)
        normals.reserveCapacity(size * size * 4)
        func hash(_ x: Int, _ y: Int) -> Float {
            var n = UInt32(truncatingIfNeeded: x &* 374761393 &+ y &* 668265263)
            n = (n ^ (n >> 13)) &* 1274126177
            return Float(n ^ (n >> 16)) / Float(UInt32.max)
        }
        func noise(_ x: Float, _ y: Float) -> Float {
            let ix = Int(floor(x)), iy = Int(floor(y))
            var tx = x - floor(x), ty = y - floor(y)
            tx = tx * tx * (3 - 2 * tx); ty = ty * ty * (3 - 2 * ty)
            let a = hash(ix, iy) * (1 - tx) + hash(ix + 1, iy) * tx
            let b = hash(ix, iy + 1) * (1 - tx) + hash(ix + 1, iy + 1) * tx
            return a * (1 - ty) + b * ty
        }
        func byte(_ value: Float) -> UInt8 { UInt8(max(0, min(255, value * 255))) }
        for y in 0..<size {
            for x in 0..<size {
                let u = Float(x) / Float(size - 1), v = Float(y) / Float(size - 1)
                let p = SIMD2<Float>(u * 1.5 - 0.6, v * 1.1 - 0.5)
                let edge = pow(min(1, surface.radialFraction(p)), 5)
                let cloud = noise(u * 9, v * 9) - 0.5
                let grain = (noise(u * 175, v * 175) - 0.5) * 0.055
                let toasted = c.browningAmount * (edge * 0.29 + cloud * 0.16)
                colors += [byte(0.89 - toasted * 0.40 + grain),
                           byte(0.675 - toasted * 0.66 + grain),
                           byte(0.380 - toasted * 0.45 + grain * 0.7), 255]
                let nx = (hash(x + 1, y) - hash(x - 1, y)) * 0.055
                let ny = (hash(x, y + 1) - hash(x, y - 1)) * 0.055
                normals += [byte(0.5 + nx), byte(0.5 + ny), 255, 255]
            }
        }
        return TexturePixels(color: colors, normal: normals, size: size)
    }

    @MainActor
    static func pastry(pixels: TexturePixels) async throws -> PhysicallyBasedMaterial {
        let color = try await TextureResource(image: image(pixels.color, size: pixels.size, color: true),
                                             options: .init(semantic: .color))
        let normal = try await TextureResource(image: image(pixels.normal, size: pixels.size, color: false),
                                              options: .init(semantic: .normal))
        var material = solid(0.91, 0.65, 0.33, roughness: 0.83)
        material.baseColor = .init(tint: .white, texture: .init(color))
        material.normal = .init(texture: .init(normal))
        return material
    }

    @MainActor
    static func mold(_ c: TaiyakiConfiguration) -> PhysicallyBasedMaterial {
        let b = Double(c.browningAmount)
        return solid(0.71 - b * 0.10, 0.43 - b * 0.06, 0.22 - b * 0.03, roughness: 0.86)
    }

    @MainActor static var crumb: PhysicallyBasedMaterial { solid(0.98, 0.84, 0.52, roughness: 0.94) }
    @MainActor static var interior: PhysicallyBasedMaterial { solid(0.19, 0.060, 0.042, roughness: 0.88) }
    @MainActor static var eye: PhysicallyBasedMaterial { solid(0.65, 0.40, 0.20, roughness: 0.83) }
    @MainActor static var logo: PhysicallyBasedMaterial { solid(0.25, 0.083, 0.025, roughness: 0.86) }

    @MainActor
    static func bean(_ index: Int) -> PhysicallyBasedMaterial {
        let colors: [(Double, Double, Double)] = [(0.31, 0.105, 0.080), (0.39, 0.151, 0.118),
                                                  (0.28, 0.078, 0.067), (0.44, 0.185, 0.140)]
        let rgb = colors[index % colors.count]
        return solid(rgb.0, rgb.1, rgb.2, roughness: 0.51)
    }

    @MainActor
    private static func solid(_ r: Double, _ g: Double, _ b: Double, roughness: Float) -> PhysicallyBasedMaterial {
        var material = PhysicallyBasedMaterial()
        material.baseColor = .init(tint: TaiyakiColor(red: r, green: g, blue: b, alpha: 1))
        material.roughness = .init(floatLiteral: roughness)
        material.metallic = .init(floatLiteral: 0)
        material.specular = .init(floatLiteral: 0.20)
        return material
    }

    private static func image(_ bytes: [UInt8], size: Int, color: Bool) throws -> CGImage {
        let data = Data(bytes) as CFData
        guard let provider = CGDataProvider(data: data),
              let space = CGColorSpace(name: color ? CGColorSpace.sRGB : CGColorSpace.linearSRGB),
              let image = CGImage(width: size, height: size, bitsPerComponent: 8, bitsPerPixel: 32,
                                  bytesPerRow: size * 4, space: space,
                                  bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue),
                                  provider: provider, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
        else { throw TaiyakiBuildError.textureCreation }
        return image
    }
}

enum TaiyakiBuildError: LocalizedError {
    case textureCreation
    var errorDescription: String? { "たい焼きの表面テクスチャを生成できませんでした。" }
}
