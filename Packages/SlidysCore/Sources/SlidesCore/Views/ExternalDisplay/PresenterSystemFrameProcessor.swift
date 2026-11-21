#if os(iOS)
import Foundation
import CoreImage
import CoreVideo
@preconcurrency import Metal

final class PresenterSystemBuffer: @unchecked Sendable {
    let buffer: CVPixelBuffer
    init(_ buffer: CVPixelBuffer) { self.buffer = buffer }
}

/// All CI rendering, pixel-buffer pool access and texture-cache access is serialized off-main.
final class PresenterSystemFrameProcessor: @unchecked Sendable {
    private let queue = DispatchQueue(label: "Slidys.ScreenCaptureKit.crop", qos: .userInteractive)
    private let context: CIContext
    private let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
    private var pool: CVPixelBufferPool?
    private var size = CGSize.zero
    private var cache: CVMetalTextureCache?

    init?(device: MTLDevice) {
        context = CIContext(mtlDevice: device, options: [.cacheIntermediates: false])
        guard CVMetalTextureCacheCreate(nil, nil, device, nil, &cache) == kCVReturnSuccess else { return nil }
    }
    func reset() {
        queue.async { [self] in
            pool = nil
            size = .zero
            context.clearCaches()
            if let cache { CVMetalTextureCacheFlush(cache, 0) }
        }
    }
    func process(_ input: PresenterSystemBuffer, layout: PresenterStreamLayout, orientation: Int, outputSize: CGSize,
                 completion: @escaping @Sendable (PresenterMetalFrame?, Double) -> Void) {
        queue.async { [self] in
            autoreleasepool {
                let start = ProcessInfo.processInfo.systemUptime
                let result = render(input.buffer, layout: layout, orientation: orientation, outputSize: outputSize)
                completion(result, (ProcessInfo.processInfo.systemUptime-start) * 1000)
            }
        }
    }
    private func render(_ input: CVPixelBuffer, layout: PresenterStreamLayout, orientation: Int, outputSize: CGSize) -> PresenterMetalFrame? {
        guard outputSize.width > 0, outputSize.height > 0,
              max(outputSize.width, outputSize.height) <= 1920,
              outputSize.width * outputSize.height <= 1920 * 1080 else { return nil }
        if pool == nil || size != outputSize {
            pool = nil
            let attributes: [String: Any] = [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
                kCVPixelBufferWidthKey as String: Int(outputSize.width),
                kCVPixelBufferHeightKey as String: Int(outputSize.height),
                kCVPixelBufferMetalCompatibilityKey as String: true,
                kCVPixelBufferIOSurfacePropertiesKey as String: [:]
            ]
            guard CVPixelBufferPoolCreate(nil, nil, attributes as CFDictionary, &pool) == kCVReturnSuccess else { return nil }
            size = outputSize
        }
        guard let pool, let cache else { return nil }
        var output: CVPixelBuffer?
        let limit = [kCVPixelBufferPoolAllocationThresholdKey as String: 3]
        guard CVPixelBufferPoolCreatePixelBufferWithAuxAttributes(nil, pool, limit as CFDictionary, &output) == kCVReturnSuccess,
              let output else { return nil }
        let image = CIImage(cvPixelBuffer: input).oriented(forExifOrientation: Int32(orientation))
        let normalized = image.transformed(by: CGAffineTransform(translationX: -image.extent.minX, y: -image.extent.minY))
        let crop = CGRect(x: layout.crop.minX, y: layout.orientedSize.height-layout.crop.maxY,
                          width: layout.crop.width, height: layout.crop.height)
        let fitted = normalized.cropped(to: crop)
            .transformed(by: CGAffineTransform(translationX: -crop.minX, y: -crop.minY))
            .transformed(by: CGAffineTransform(scaleX: outputSize.width/crop.width, y: outputSize.height/crop.height))
        context.render(fitted, to: output, bounds: CGRect(origin: .zero, size: outputSize), colorSpace: colorSpace)
        var wrapper: CVMetalTexture?
        guard CVMetalTextureCacheCreateTextureFromImage(nil, cache, output, nil, .bgra8Unorm,
                                                        Int(outputSize.width), Int(outputSize.height), 0, &wrapper) == kCVReturnSuccess,
              let wrapper, let texture = CVMetalTextureGetTexture(wrapper) else { return nil }
        return PresenterMetalFrame(buffer: output, metalTexture: wrapper, texture: texture, complete: true)
    }
}
#endif
