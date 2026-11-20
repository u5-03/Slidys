#if os(iOS)
import UIKit
import CoreVideo
@preconcurrency import Metal
@preconcurrency import QuartzCore

/// Immutable lease. Keep BOTH the CV buffer and its texture wrapper alive until GPU completion.
final class PresenterMetalFrame: @unchecked Sendable {
    let buffer: CVPixelBuffer
    let metalTexture: CVMetalTexture
    let texture: MTLTexture
    let complete: Bool
    let bytes: Int
    var size: CGSize { CGSize(width: texture.width, height: texture.height) }

    init(buffer: CVPixelBuffer, metalTexture: CVMetalTexture, texture: MTLTexture, complete: Bool) {
        self.buffer = buffer
        self.metalTexture = metalTexture
        self.texture = texture
        self.complete = complete
        bytes = CVPixelBufferGetBytesPerRow(buffer) * CVPixelBufferGetHeight(buffer)
    }
}

@MainActor
final class PresenterMetalFramePool {
    private var textureCache: CVMetalTextureCache?
    private var pool: CVPixelBufferPool?
    private var size: CGSize = .zero
    private let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
    static let bufferLimit = 3

    init?(device: MTLDevice) {
        guard CVMetalTextureCacheCreate(nil, nil, device, nil, &textureCache) == kCVReturnSuccess else { return nil }
    }

    func reset() {
        pool = nil
        size = .zero
        if let textureCache { CVMetalTextureCacheFlush(textureCache, 0) }
    }

    func capture(source: UIView, pixels: CGSize) -> PresenterMetalFrame? {
        guard pixels.width > 0, pixels.height > 0,
              pixels.width <= 1920, pixels.height <= 1920,
              pixels.width * pixels.height <= 1920 * 1080,
              source.bounds.width > 1, source.bounds.height > 1 else { return nil }
        if pool == nil || size != pixels {
            reset()
            let attributes: [String: Any] = [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
                kCVPixelBufferWidthKey as String: Int(pixels.width),
                kCVPixelBufferHeightKey as String: Int(pixels.height),
                kCVPixelBufferMetalCompatibilityKey as String: true,
                kCVPixelBufferCGImageCompatibilityKey as String: true,
                kCVPixelBufferCGBitmapContextCompatibilityKey as String: true,
                kCVPixelBufferIOSurfacePropertiesKey as String: [:]
            ]
            let poolAttributes = [kCVPixelBufferPoolMinimumBufferCountKey as String: 2]
            guard CVPixelBufferPoolCreate(nil, poolAttributes as CFDictionary, attributes as CFDictionary, &pool) == kCVReturnSuccess else { return nil }
            size = pixels
        }
        guard let pool, let textureCache else { return nil }
        var buffer: CVPixelBuffer?
        let allocation = [kCVPixelBufferPoolAllocationThresholdKey as String: Self.bufferLimit]
        guard CVPixelBufferPoolCreatePixelBufferWithAuxAttributes(nil, pool, allocation as CFDictionary, &buffer) == kCVReturnSuccess,
              let buffer else { return nil }
        guard CVPixelBufferLockBaseAddress(buffer, []) == kCVReturnSuccess else { return nil }
        var complete = false
        do {
            defer { CVPixelBufferUnlockBaseAddress(buffer, []) }
            guard let address = CVPixelBufferGetBaseAddress(buffer),
                  let context = CGContext(data: address, width: Int(pixels.width), height: Int(pixels.height),
                                          bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                                          space: colorSpace,
                                          bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue) else { return nil }
            context.setFillColor(UIColor.black.cgColor)
            context.fill(CGRect(origin: .zero, size: pixels))
            // CGContext is bottom-up; UIKit snapshots use top-left coordinates.
            context.translateBy(x: 0, y: pixels.height)
            context.scaleBy(x: pixels.width / source.bounds.width, y: -pixels.height / source.bounds.height)
            context.translateBy(x: -source.bounds.minX, y: -source.bounds.minY)
            UIGraphicsPushContext(context)
            complete = source.drawHierarchy(in: source.bounds, afterScreenUpdates: false)
            UIGraphicsPopContext()
        }
        var wrapper: CVMetalTexture?
        guard CVMetalTextureCacheCreateTextureFromImage(nil, textureCache, buffer, nil, .bgra8Unorm,
                                                        Int(pixels.width), Int(pixels.height), 0, &wrapper) == kCVReturnSuccess,
              let wrapper, let texture = CVMetalTextureGetTexture(wrapper) else { return nil }
        return PresenterMetalFrame(buffer: buffer, metalTexture: wrapper, texture: texture, complete: complete)
    }
}

/// The worker owns GPU submission; UIKit rendering never waits for a drawable or GPU completion.
final class PresenterMetalRenderer: @unchecked Sendable {
    struct Target: @unchecked Sendable {
        let layer: CAMetalLayer
    }
    let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private let pipeline: MTLRenderPipelineState
    private let worker = DispatchQueue(label: "Slidys.PresenterMetal", qos: .userInteractive)

    init?() {
        guard let device = MTLCreateSystemDefaultDevice(), let queue = device.makeCommandQueue() else { return nil }
        let source = """
        #include <metal_stdlib>
        using namespace metal;
        struct Vertex { float4 position [[position]]; float2 uv; };
        vertex Vertex presenterVertex(uint index [[vertex_id]]) {
            float2 positions[3] = {float2(-1,-1), float2(3,-1), float2(-1,3)};
            Vertex result;
            result.position = float4(positions[index], 0, 1);
            result.uv = float2((positions[index].x + 1) * 0.5, (1 - positions[index].y) * 0.5);
            return result;
        }
        fragment float4 presenterFragment(Vertex input [[stage_in]], texture2d<float> image [[texture(0)]]) {
            constexpr sampler linearSampler(coord::normalized, address::clamp_to_edge, filter::linear);
            return image.sample(linearSampler, input.uv);
        }
        """
        do {
            let library = try device.makeLibrary(source: source, options: nil)
            let descriptor = MTLRenderPipelineDescriptor()
            descriptor.vertexFunction = library.makeFunction(name: "presenterVertex")
            descriptor.fragmentFunction = library.makeFunction(name: "presenterFragment")
            descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
            pipeline = try device.makeRenderPipelineState(descriptor: descriptor)
        } catch { return nil }
        self.device = device
        commandQueue = queue
    }

    func present(_ frame: PresenterMetalFrame, to targets: [Target], completion: @escaping @Sendable (Double, Int, Bool) -> Void) {
        worker.async { [self] in
            autoreleasepool {
                let started = ProcessInfo.processInfo.systemUptime
                guard let command = commandQueue.makeCommandBuffer() else { completion(0, 0, false); return }
                var submitted = 0
                for target in targets {
                    guard let drawable = target.layer.nextDrawable() else { continue }
                    let width = Double(drawable.texture.width), height = Double(drawable.texture.height)
                    let scale = min(width / Double(frame.texture.width), height / Double(frame.texture.height))
                    let fittedWidth = Double(frame.texture.width) * scale
                    let fittedHeight = Double(frame.texture.height) * scale
                    let pass = MTLRenderPassDescriptor()
                    pass.colorAttachments[0].texture = drawable.texture
                    pass.colorAttachments[0].loadAction = .clear
                    pass.colorAttachments[0].storeAction = .store
                    pass.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1)
                    guard let encoder = command.makeRenderCommandEncoder(descriptor: pass) else { continue }
                    encoder.setRenderPipelineState(pipeline)
                    encoder.setViewport(MTLViewport(originX: (width - fittedWidth) / 2, originY: (height - fittedHeight) / 2,
                                                    width: fittedWidth, height: fittedHeight, znear: 0, zfar: 1))
                    encoder.setFragmentTexture(frame.texture, index: 0)
                    encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
                    encoder.endEncoding()
                    command.present(drawable)
                    submitted += 1
                }
                let count = submitted
                command.addCompletedHandler { [frame] buffer in
                    // Keep the IOSurface and CVMetalTexture lease until every destination is done.
                    withExtendedLifetime(frame) {
                        completion((ProcessInfo.processInfo.systemUptime - started) * 1000, count, buffer.status == .completed)
                    }
                }
                command.commit()
            }
        }
    }
}
#endif

#if DEBUG && os(iOS)
import SwiftUI

/// Capture a real UIKit subtree, with an overlapping sibling that must stay local.
final class PresenterMetalCheckView: UIView {
    private let source = UIView()
    private let top = UIView()
    private let bottom = UIView()
    private let localMenu = UILabel()
    private let status = UILabel()
    private let output = CAMetalLayer()
    private let renderer = PresenterMetalRenderer()
    private var pool: PresenterMetalFramePool?
    private var started = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        top.backgroundColor = .red
        bottom.backgroundColor = .blue
        source.addSubview(top)
        source.addSubview(bottom)
        let text = UILabel(frame: CGRect(x: 15, y: 20, width: 300, height: 60))
        text.text = "TOP / SLIDE"
        text.font = .boldSystemFont(ofSize: 30)
        text.textColor = .white
        source.addSubview(text)
        addSubview(source)
        localMenu.text = "LOCAL MENU"
        localMenu.backgroundColor = .green
        localMenu.textColor = .black
        addSubview(localMenu)
        status.textColor = .white
        status.numberOfLines = 0
        status.text = "Source (left) / Metal output (right)"
        addSubview(status)
        if let renderer {
            pool = PresenterMetalFramePool(device: renderer.device)
            output.device = renderer.device
        }
        output.pixelFormat = .bgra8Unorm
        output.framebufferOnly = true
        output.maximumDrawableCount = 2
        layer.addSublayer(output)
    }
    required init?(coder: NSCoder) { fatalError() }
    override func layoutSubviews() {
        super.layoutSubviews()
        source.frame = CGRect(x: 10, y: 30, width: 400, height: 225)
        top.frame = CGRect(x: 0, y: 0, width: 400, height: 112.5)
        bottom.frame = CGRect(x: 0, y: 112.5, width: 400, height: 112.5)
        localMenu.frame = CGRect(x: 280, y: 80, width: 130, height: 70)
        output.frame = CGRect(x: 440, y: 30, width: 400, height: 225)
        output.drawableSize = CGSize(width: 1280, height: 720)
        status.frame = CGRect(x: 10, y: 275, width: 830, height: 80)
    }
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard window != nil, !started else { return }
        started = true
        layoutIfNeeded()
        check()
    }
    private func check() {
        guard let pool, let renderer else { status.text = "FAIL: Metal initialization"; return }
        var leases: [PresenterMetalFrame] = []
        for _ in 0..<3 {
            guard let frame = pool.capture(source: source, pixels: CGSize(width: 1280, height: 720) ) else {
                status.text = "FAIL: capture"; return
            }
            leases.append(frame)
        }
        let bounded = pool.capture(source: source, pixels: CGSize(width: 1280, height: 720) ) == nil
        let frame = leases[0]
        let complete = frame.complete
        let mirror = PresenterSlideMirrorUIView(frame: .zero)
        mirror.clearFrame()
        let eligibleAfterClear = !mirror.isHidden
        status.text = "captureComplete=\(complete) poolLimit3=\(bounded) GPU pending"
        renderer.present(frame, to: [.init(layer: output)]) { [weak self] _, count, success in
            Task { @MainActor [weak self] in
                self?.status.text = "GPU command=\(success && count == 1 ? "PASS" : "FAIL")  captureComplete=\(complete)  poolLimit3=\(bounded ? "PASS" : "FAIL") outputEligible=\(eligibleAfterClear ? "PASS" : "FAIL")\nPreview capture may be unavailable; verify actual imagery on device."
            }
        }
    }
}

struct PresenterMetalCheck: UIViewRepresentable {
    func makeUIView(context: Context) -> PresenterMetalCheckView { PresenterMetalCheckView() }
    func updateUIView(_ view: PresenterMetalCheckView, context: Context) {}
}

#endif
