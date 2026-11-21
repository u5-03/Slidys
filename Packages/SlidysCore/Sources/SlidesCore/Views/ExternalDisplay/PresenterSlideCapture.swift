import SwiftUI

public enum PresenterSlideOutput: String, CaseIterable, Identifiable {
    case independent
    case capture
    case systemCapture
    public var usesCapturedSlides: Bool { self != .independent }
    public var id: String { rawValue }
    public var title: String {
        switch self {
        case .independent: "通常表示（従来）"
        case .capture: "手元の操作を映す"
        case .systemCapture: "手元の操作を映す（画面全体・試験）"
        }
    }
}

#if os(iOS)
import UIKit
import OSLog
import Darwin
import Metal
import QuartzCore
import CoreMedia
#if canImport(ScreenCaptureKit) && !targetEnvironment(macCatalyst)
import ScreenCaptureKit
#endif

private let presenterCaptureLogger = Logger(subsystem: "Slidys", category: "PresenterCapture")

/// One producer for all output displays. Only a bounded bitmap is retained, never a
/// chain of render-server snapshot views containing the entire source window.
@MainActor
final class PresenterSlideCapture: ObservableObject {
    static let shared = PresenterSlideCapture()
    @Published var output: PresenterSlideOutput = .independent {
        didSet {
            if oldValue != output {
                resetSystemCapture()
                link?.preferredFrameRateRange = output == .systemCapture
                    ? CAFrameRateRange(minimum: 5, maximum: 5, preferred: 5)
                    : CAFrameRateRange(minimum: min(15, targetFPS), maximum: targetFPS, preferred: targetFPS)
            }
            ExternalDisplayCoordinator.shared.refreshOutputRouting()
            diagnostics("mode old=\(oldValue.rawValue) new=\(output.rawValue)")
        }
    }
    private final class SourceReference {
        weak var view: UIView?
        init(_ view: UIView) { self.view = view }
    }
    private var sources: [SourceReference] = []
    private let outputs = NSHashTable<PresenterSlideMirrorUIView>.weakObjects()
    private var link: CADisplayLink?
    var isCapturingFrames: Bool { link != nil }
    private var watchdog: Timer?
    private var ticker: CaptureFrameTicker?
    private var lastTick: TimeInterval = 0
    private var lastReport = ""
    private var frame: PresenterMetalFrame?
    let metalRenderer = PresenterMetalRenderer()
    private lazy var framePool: PresenterMetalFramePool? = {
        guard let device = metalRenderer?.device else { return nil }
        return PresenterMetalFramePool(device: device)
    }()
    @Published private(set) var captureStatus: String?
    private var systemStorage: AnyObject?
    private var systemGeneration = UUID()
    private var systemSourceWindow: ObjectIdentifier?
    private var systemProcessor: PresenterSystemFrameProcessor?
    private var systemLastPacket: TimeInterval?
    private var systemLastForwarded: TimeInterval?
    private var systemLastHeartbeat: TimeInterval = 0
    private var systemGeometry = ""
    private var systemInvalidGeometrySince: TimeInterval?
    private var systemFailure: String?
    private var systemNonCompleteFrames = 0
    private var systemReceivedFrames = 0
    private var systemRejectedFrames = 0
    private var systemCropMS: Double = 0
    private var systemCompletedFrames = 0
    private var systemFailedFrames = 0
    private var systemSubmitMS: Double = 0
    private var systemMetricsStart = ProcessInfo.processInfo.systemUptime
    private var inFlight = 0
    private var busyDrops = 0
    private var gpuFrames = 0
    private var gpuFailures = 0
    private var gpuTotalMS: Double = 0
    private var nextOuterCaptureTime: TimeInterval = 0
    private var throttleSkips = 0
    private var targetFPS: Float = 30
    private var supportedFPS = 60
    private var lastPacingUpdate: TimeInterval = 0
    private var smoothedCaptureMS: Double = 0
    private var lastStallDiagnostic: TimeInterval = 0
    private var observers: [NSObjectProtocol] = []
    private var metricsStart = ProcessInfo.processInfo.systemUptime
    private var renderedFrames = 0
    private var incompleteFrames = 0
    private var fallbackTicks = 0
    private var renderMilliseconds: Double = 0
    private var peakFootprintMB: Double = 0

    /// Process-wide footprint includes RealityKit/WebKit and OS rendering allocations.
    func diagnostics(_ event: String) {
        var info = task_vm_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<integer_t>.size)
        let status = withUnsafeMutablePointer(to: &info) { pointer in
            pointer.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
            }
        }
        let footprint = status == KERN_SUCCESS ? Double(info.phys_footprint) / 1_048_576 : -1
        peakFootprintMB = max(peakFootprintMB, footprint)
        let available = Double(os_proc_available_memory()) / 1_048_576
        let imageBytes = frame?.bytes ?? 0
        presenterCaptureLogger.notice("[PresenterCapture] \(event, privacy: .public) uptime=\(ProcessInfo.processInfo.systemUptime) footprintMB=\(footprint) peakObservedMB=\(self.peakFootprintMB) availableMB=\(available) frameBytes=\(imageBytes) outputs=\(self.outputs.allObjects.count) sources=\(self.sources.compactMap(\.view).count)")
    }

    static let maximumPixelDimension: CGFloat = 1920

    private init() {
        let center = NotificationCenter.default
        observers.append(center.addObserver(forName: UIApplication.didReceiveMemoryWarningNotification, object: nil, queue: .main) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.diagnostics("memory-warning before-clear")
                self?.clearFrame()
                self?.diagnostics("memory-warning after-clear")
            }
        })
        observers.append(center.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { [weak self] _ in
            MainActor.assumeIsolated { self?.stopDriver() }
        })
        observers.append(center.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [weak self] _ in
            MainActor.assumeIsolated { self?.startIfNeeded() }
        })
    }

    static func supportsSource(_ scene: UIWindowScene) -> Bool {
        if scene.session.role == .windowApplication { return true }
#if canImport(UIKit, _version: 9127.0.85)
        if #available(iOS 27.1, *), scene.session.role == .windowCameraCaptureAccessory { return true }
#endif
        return false
    }

    var source: UIView? {
        let swapsDisplays = DualDisplayCaptureKeeper.shared.isRunning
            && DualDisplayCaptureKeeper.shared.displayMode == .innerSlides
        return sources.reversed().compactMap(\.view).first { view in
            guard let window = view.window, let scene = window.windowScene,
                  Self.supportsSource(scene), scene.activationState != .background,
                  scene.activationState != .unattached else { return false }
            // Swapped Duo mode takes input from the outer notes, not the audience's inner view.
            if swapsDisplays && scene.session.role == .windowApplication { return false }
            if !swapsDisplays && scene.session.role != .windowApplication { return false }
            return !window.isHidden && !view.isHidden && view.alpha > 0
                && view.bounds.width > 1 && view.bounds.height > 1
        }
    }

    func register(_ view: UIView) {
        sources.removeAll { $0.view == nil }
        // A source can be mounted after an existing output's transition; restart independently
        // of whether SwiftUI recreated the output representable.
        startIfNeeded()
        guard !sources.contains(where: { $0.view === view }) else { return }
        sources.append(SourceReference(view))
        diagnostics("source registered")
    }
    func unregister(_ view: UIView) {
        sources.removeAll { $0.view == nil || $0.view === view }
        if source == nil { clearFrame() }
        diagnostics("source unregistered")
    }
    func addOutput(_ view: PresenterSlideMirrorUIView) {
        outputs.add(view)
        view.clearFrame()
        startIfNeeded()
        diagnostics("output attached")
    }
    func removeOutput(_ view: PresenterSlideMirrorUIView) {
        outputs.remove(view)
        if outputs.allObjects.isEmpty { stopDriver() }
        diagnostics("output detached")
    }

    private var prioritizesPresenter: Bool {
        output == .independent
            && ExternalDisplayCoordinator.shared.effectiveMode == .systemMirroring
            && DualDisplayCaptureKeeper.shared.isRunning
            && DualDisplayCaptureKeeper.shared.displayMode == .mirroredSlides
    }

    private var needsFrameDriver: Bool {
        // HDMI may mirror through UIKit while Duo still consumes captured frames.
        ExternalDisplayCoordinator.shared.effectiveMode != .systemMirroring
            || (DualDisplayCaptureKeeper.shared.isRunning && DualDisplayCaptureKeeper.shared.displayMode == .mirroredSlides)
    }

    private func startIfNeeded() {
        guard needsFrameDriver,
              link == nil, !outputs.allObjects.isEmpty else { return }
        targetFPS = prioritizesPresenter ? 2 : 30
        nextOuterCaptureTime = 0
        throttleSkips = 0
        smoothedCaptureMS = 0
        metricsStart = ProcessInfo.processInfo.systemUptime
        renderedFrames = 0
        incompleteFrames = 0
        fallbackTicks = 0
        renderMilliseconds = 0
        diagnostics("driver start backend=metal targetFPS=\(targetFPS) presenterPriority=\(prioritizesPresenter) maximumPixels=1920 maximumArea=2073600 poolLimit=3 inFlightLimit=2")
        let ticker = CaptureFrameTicker(self)
        self.ticker = ticker
        let link = CADisplayLink(target: ticker, selector: #selector(CaptureFrameTicker.tick))
        link.preferredFrameRateRange = output == .systemCapture
            ? CAFrameRateRange(minimum: 5, maximum: 5, preferred: 5)
            : CAFrameRateRange(minimum: min(15, targetFPS), maximum: targetFPS, preferred: targetFPS)
        link.add(to: .main, forMode: .common)
        self.link = link
        lastTick = Date.timeIntervalSinceReferenceDate
        let timer = Timer(timeInterval: 0.25, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated {
                guard let self, Date.timeIntervalSinceReferenceDate - self.lastTick > 0.2 else { return }
                self.fallbackTicks += 1
                self.tick()
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        watchdog = timer
    }
    private func stopDriver() {
        let wasRunning = link != nil
        link?.invalidate()
        link = nil
        watchdog?.invalidate()
        watchdog = nil
        ticker = nil
        clearFrame()
        if wasRunning { resetSystemCapture(); diagnostics("driver stopped frame-released") }
    }
    private func clearFrame() {
        frame = nil
        framePool?.reset()
        outputs.allObjects.forEach { $0.clearFrame() }
    }
    private func report(_ message: String) {
        guard lastReport != message else { return }
        lastReport = message
        presenterCaptureLogger.notice("[PresenterCapture] \(message, privacy: .public)")
    }

    func restartSystemCapture() {
        resetSystemCapture()
        if let window = source?.window { ensureSystemCapture(window: window) }
    }

    private func resetSystemCapture() {
#if canImport(ScreenCaptureKit) && !targetEnvironment(macCatalyst)
        if #available(iOS 27.0, *), let capture = systemStorage as? PresenterSystemCapture { capture.stop() }
#endif
        systemStorage = nil
        systemLastPacket = nil
        systemLastForwarded = nil
        systemLastHeartbeat = 0
        systemGeometry = ""
        systemInvalidGeometrySince = nil
        systemFailure = nil
        systemNonCompleteFrames = 0
        systemSourceWindow = nil
        systemGeneration = UUID()
        systemProcessor?.reset()
        captureStatus = nil
        systemMetricsStart = ProcessInfo.processInfo.systemUptime
        systemReceivedFrames = 0
        renderedFrames = 0
        systemRejectedFrames = 0
        systemCropMS = 0
        systemCompletedFrames = 0
        systemFailedFrames = 0
        systemSubmitMS = 0
    }

    private func failSystemCapture(_ reason: String) {
        guard output == .systemCapture, systemFailure == nil else { return }
        systemFailure = reason
        diagnostics("system failed backend=screencapturekit automaticFallback=false reason=\(reason)")
#if canImport(ScreenCaptureKit) && !targetEnvironment(macCatalyst)
        if #available(iOS 27.0, *), let capture = systemStorage as? PresenterSystemCapture { capture.stop() }
#endif
        systemGeneration = UUID()
        clearFrame()
        captureStatus = "画面全体の取得に失敗しました。共有を選び直すか、出力方式を変更してください"
    }

    private func ensureSystemCapture(window: UIWindow) {
        guard systemFailure == nil else { return }
#if canImport(ScreenCaptureKit) && !targetEnvironment(macCatalyst)
        if #available(iOS 27.0, *) {
            if systemSourceWindow != nil && systemSourceWindow != ObjectIdentifier(window) { resetSystemCapture() }
            if systemStorage == nil {
                if systemProcessor == nil, let device = metalRenderer?.device { systemProcessor = PresenterSystemFrameProcessor(device: device) }
                systemSourceWindow = ObjectIdentifier(window)
                systemStorage = PresenterSystemCapture(onFrame: { [weak self] packet in self?.consumeSystemFrame(packet) }, status: { [weak self] message in
                    guard let self, self.systemFailure == nil else { return }
                    self.captureStatus = message
                    if let message { self.diagnostics("system status=\(message)") }
                }, failure: { [weak self] reason in
                    self?.failSystemCapture(reason)
                })
            }
            (systemStorage as? PresenterSystemCapture)?.request(window: window)
        } else { captureStatus = "画面共有にはiOS 27以降が必要です" }
#else
        captureStatus = "この環境では映像ストリームの取得に対応していません"
#endif
    }

#if canImport(ScreenCaptureKit) && !targetEnvironment(macCatalyst)
    @available(iOS 27.0, *)
    private func consumeSystemFrame(_ packet: PresenterStreamPacket) {
        guard output == .systemCapture, systemFailure == nil, let capture = systemStorage as? PresenterSystemCapture,
              capture.isCurrent(packet), let source, let window = source.window,
              let buffer = CMSampleBufferGetImageBuffer(packet.sample) else { return }
        if systemLastPacket == nil { systemMetricsStart = ProcessInfo.processInfo.systemUptime }
        systemLastPacket = ProcessInfo.processInfo.systemUptime
        let attachments = CMSampleBufferGetSampleAttachmentsArray(packet.sample, createIfNecessary: false) as? [[SCStreamFrameInfo: Any]]
        guard let info = attachments?.first,
              (info[.status] as? NSNumber)?.intValue == SCFrameStatus.complete.rawValue else {
            systemNonCompleteFrames += 1
            return
        }
        systemReceivedFrames += 1
        // Some iOS streams omit videoOrientation entirely (confirmed on device).
        // Treat such frames in their delivered surface coordinates. Do not infer
        // orientation from UIDevice: window/content size validation below still
        // rejects another display or an axis-mismatched frame.
        let explicitOrientation = (info[.videoOrientation] as? NSNumber)?.intValue
        let orientation = explicitOrientation ?? 1
        guard let density = (info[.scaleFactor] as? NSNumber)?.doubleValue,
              let content = Self.streamRect(info[.contentRect]) else {
            systemRejectedFrames += 1
            captureStatus = "映像の座標情報を取得できません。共有を選び直してください"
            let fields = info.map { key, value in
                "\(key.rawValue):\(String(reflecting: type(of: value)))=\(String(describing: value))"
            }.sorted().joined(separator: "; ")
            reportStall("system-metadata-missing orientation=\(info[.videoOrientation] != nil) density=\(info[.scaleFactor] != nil) content=\(info[.contentRect] != nil) fields=[\(fields)]")
            return
        }
        let rawSize = CGSize(width: CVPixelBufferGetWidth(buffer), height: CVPixelBufferGetHeight(buffer))
        let scale = (info[.contentScale] as? NSNumber)?.doubleValue ?? 1
        let pixels = content.applying(CGAffineTransform(scaleX: density * scale, y: density * scale))
        var capturedSize = capture.filterRect.size
        if let screen = Self.streamRect(info[.screenRect]), screen.width > 0, screen.height > 0 {
            capturedSize = screen.size
        }
        // Full-display frames are in screen coordinates, not UIWindow coordinates.
        let slideInWindow = source.convert(source.bounds, to: window)
        let slide = window.convert(slideInWindow, to: window.screen.coordinateSpace)
        let displayBounds = window.screen.bounds
        guard let layout = PresenterStreamLayout.make(buffer: rawSize, contentPixels: pixels, orientation: orientation,
                                                       capturedWindow: capturedSize, sourceWindow: displayBounds, slide: slide) else {
            systemRejectedFrames += 1
            captureStatus = "取得した画面と手元の画面が一致するか確認しています"
            let now = ProcessInfo.processInfo.systemUptime
            if systemInvalidGeometrySince == nil { systemInvalidGeometrySince = now }
            reportStall("system-geometry-rejected orientationSource=\(explicitOrientation == nil ? "surface" : "metadata") raw=\(rawSize) content=\(content) density=\(density) scale=\(scale) orientation=\(orientation) captured=\(capturedSize) window=\(window.bounds) screen=\(displayBounds) slide=\(slide)")
            if now-(systemInvalidGeometrySince ?? now) >= 3 {
                failSystemCapture("source-display-mismatch captured=\(capturedSize) expectedScreen=\(displayBounds) window=\(window.bounds)")
            }
            return
        }
        systemInvalidGeometrySince = nil
        let destinations = outputs.allObjects.filter { $0.window != nil && $0.window !== window && !$0.isHidden }
        let sizes = destinations.compactMap { view -> CGSize? in
            guard let window = view.window else { return nil }
            return CGSize(width: view.bounds.width * window.screen.scale, height: view.bounds.height * window.screen.scale)
        }
        guard !destinations.isEmpty, let outputSize = PresenterCaptureResolution.pixels(source: source.bounds.size, destinations: sizes),
              let systemProcessor, inFlight < 2 else { busyDrops += 1; return }
        let geometry = "orientationSource=\(explicitOrientation == nil ? "surface" : "metadata") raw=\(rawSize) content=\(content) density=\(density) scale=\(scale) orientation=\(orientation) captured=\(capturedSize) window=\(window.bounds) screen=\(displayBounds) slide=\(slide) crop=\(layout.crop) output=\(outputSize) destinations=\(sizes)"
        if geometry != systemGeometry {
            systemGeometry = geometry
            diagnostics("system geometry \(geometry) sourceRole=\(window.windowScene?.session.role.rawValue ?? "none") sourceMaxFPS=\(window.screen.maximumFramesPerSecond)")
        }
        inFlight += 1
        let generation = systemGeneration
        systemProcessor.process(PresenterSystemBuffer(buffer), layout: layout, orientation: orientation, outputSize: outputSize) { [weak self] result, milliseconds in
            Task { @MainActor [weak self] in
                guard let self else { return }
                guard self.systemGeneration == generation, self.output == .systemCapture else { self.inFlight -= 1; return }
                guard let result, let metalRenderer = self.metalRenderer else {
                    self.inFlight -= 1
                    self.reportStall("system-gpu-crop-unavailable")
                    return
                }
                if self.systemLastForwarded == nil { self.diagnostics("system first-frame-forwarded") }
                self.systemLastForwarded = ProcessInfo.processInfo.systemUptime
                self.captureStatus = nil
                self.frame = result
                self.renderedFrames += 1
                self.systemCropMS += milliseconds
                let targets = self.outputs.allObjects.filter { $0.window != nil && $0.window !== window && !$0.isHidden }.map { $0.metalTarget() }
                let expected = targets.count
                metalRenderer.present(result, to: targets) { [weak self] duration, count, success in
                    Task { @MainActor [weak self] in
                        guard let self else { return }
                        self.inFlight -= 1
                        guard self.systemGeneration == generation, self.output == .systemCapture else { return }
                        self.systemCompletedFrames += 1
                        self.systemSubmitMS += duration
                        if !success || count < expected { self.systemFailedFrames += 1 }
                    }
                }
                let elapsed = ProcessInfo.processInfo.systemUptime-self.systemMetricsStart
                if elapsed >= 5 {
                    self.diagnostics("stats backend=screencapturekit gpuCompleted=\(self.systemCompletedFrames) gpuFailures=\(self.systemFailedFrames) completedFPS=\(Double(self.systemCompletedFrames)/elapsed) inFlight=\(self.inFlight) consumedFPS=\(Double(self.systemReceivedFrames)/elapsed) forwardedFPS=\(Double(self.renderedFrames)/elapsed) rejected=\(self.systemRejectedFrames) busyDrops=\(self.busyDrops) meanSubmitToCompleteMS=\(self.systemSubmitMS/Double(max(self.systemCompletedFrames,1))) meanCropMS=\(self.systemCropMS/Double(max(self.renderedFrames,1))) raw=\(rawSize) output=\(outputSize) orientation=\(orientation) sourceRole=\(window.windowScene?.session.role.rawValue ?? "none")")
                    self.systemMetricsStart = ProcessInfo.processInfo.systemUptime
                    self.systemReceivedFrames = 0
                    self.renderedFrames = 0
                    self.systemRejectedFrames = 0
                    self.busyDrops = 0
                    self.systemCropMS = 0
                    self.systemCompletedFrames = 0
                    self.systemFailedFrames = 0
                    self.systemSubmitMS = 0
                }
            }
        }
    }
#endif

    /// ScreenCaptureKit attachments can bridge rects as CGRect/NSValue or dictionaries.
    /// Do not infer missing geometry from the current device orientation: the stream
    /// may belong to another Scene or still contain a frame from before rotation.
    private static func streamRect(_ value: Any?) -> CGRect? {
        if let rect = value as? CGRect { return rect }
        if let dictionary = value as? NSDictionary {
            return CGRect(dictionaryRepresentation: dictionary as CFDictionary)
        }
        if let value = value as? NSValue,
           String(cString: value.objCType) == String(cString: NSValue(cgRect: .zero).objCType) {
            return value.cgRectValue
        }
        return nil
    }

    private func reportStall(_ reason: String) {
        let now = ProcessInfo.processInfo.systemUptime
        guard now - lastStallDiagnostic >= 5 else { return }
        lastStallDiagnostic = now
        diagnostics("capture stalled reason=\(reason) inFlight=\(inFlight) busyDrops=\(busyDrops) incomplete=\(incompleteFrames)")
    }

    func tick() {
        if !needsFrameDriver {
            stopDriver()
            return
        }
        lastTick = Date.timeIntervalSinceReferenceDate
        let destinations = outputs.allObjects.filter { $0.window != nil && !$0.isHidden }
        guard !destinations.isEmpty else {
            // Temporary hiding during a SwiftUI transition is not an output detach.
            // Keep the driver alive so it can recover when the same view reappears.
            if outputs.allObjects.isEmpty { stopDriver() }
            else { reportStall("outputs-temporarily-hidden") }
            return
        }
        guard let source, let window = source.window else {
            report("waiting for visible slide source")
            clearFrame()
            return
        }
        if output == .systemCapture {
            ensureSystemCapture(window: window)
            let now = ProcessInfo.processInfo.systemUptime
#if canImport(ScreenCaptureKit) && !targetEnvironment(macCatalyst)
            if #available(iOS 27.0, *), let capture = systemStorage as? PresenterSystemCapture,
               let started = capture.startedAt, systemLastPacket == nil, now-started > 10 {
                failSystemCapture("stream-started-but-no-packets-after-10s")
            }
#endif
            if now-systemLastHeartbeat >= 5 {
                systemLastHeartbeat = now
                let packetAge = systemLastPacket.map { String(format: "%.2f", now-$0) } ?? "never"
                let frameAge = systemLastForwarded.map { String(format: "%.2f", now-$0) } ?? "never"
                diagnostics("system heartbeat packetAgeSeconds=\(packetAge) forwardedAgeSeconds=\(frameAge) nonCompleteTotal=\(systemNonCompleteFrames) inFlight=\(inFlight) busyDrops=\(busyDrops) status=\(captureStatus ?? "ready") sourceRole=\(window.windowScene?.session.role.rawValue ?? "none") duoRunning=\(DualDisplayCaptureKeeper.shared.isRunning) duoMode=\(DualDisplayCaptureKeeper.shared.displayMode.rawValue) externalConnected=\(ExternalDisplayCoordinator.shared.isConnected) externalMode=\(ExternalDisplayCoordinator.shared.preferredMode) thermal=\(ProcessInfo.processInfo.thermalState.rawValue) lowPower=\(ProcessInfo.processInfo.isLowPowerModeEnabled)")
            }
            return
        }
        // A display link may be clamped to the hardware minimum refresh rate and
        // the watchdog also calls tick(). Enforce the quiet period in BOTH paths.
        if prioritizesPresenter && ProcessInfo.processInfo.systemUptime < nextOuterCaptureTime {
            throttleSkips += 1
            return
        }
        let rect = source.convert(source.bounds, to: window)
        // SwiftUI can scale/rotate the hosting view without its logical bounds fitting
        // inside UIWindow.bounds. We capture the subtree in LOCAL coordinates, so a
        // full-window crop containment check incorrectly rejects a valid slide.
        let captureSize = source.bounds.size
        guard captureSize.width.isFinite, captureSize.height.isFinite,
              captureSize.width > 1, captureSize.height > 1 else {
            reportStall("source-local-layout-unavailable")
            return
        }
        // Resolve each destination in physical pixels; render only the largest needed image.
        let destinationPixels = destinations.filter { $0.window !== window }.compactMap { destination -> CGSize? in
            guard let destinationWindow = destination.window else { return nil }
            let scale = destinationWindow.screen.scale
            return CGSize(width: destination.bounds.width * scale, height: destination.bounds.height * scale)
        }
        guard let pixelSize = PresenterCaptureResolution.pixels(source: captureSize, destinations: destinationPixels) else { return }
        guard inFlight < 2 else { busyDrops += 1; reportStall("gpu-busy"); return }
        guard let metalRenderer, let framePool else { reportStall("metal-unavailable"); return }
        let renderStart = ProcessInfo.processInfo.systemUptime
        guard let result = autoreleasepool(invoking: { framePool.capture(source: source, pixels: pixelSize) }) else {
            reportStall("pixel-buffer-or-context-unavailable")
            return
        }
        if !result.complete {
            incompleteFrames += 1
            // UIKit may report incomplete for a WebKit/Metal sublayer while the rest
            // of the bitmap is current. Do not freeze the ENTIRE slide indefinitely.
            reportStall("partial-slide-frame-forwarded")
        }
        renderedFrames += 1
        let captureMS = (ProcessInfo.processInfo.systemUptime - renderStart) * 1000
        renderMilliseconds += captureMS
        if prioritizesPresenter {
            nextOuterCaptureTime = ProcessInfo.processInfo.systemUptime
                + PresenterCapturePacing.outerQuietPeriod(captureMS: captureMS)
        }
        smoothedCaptureMS = smoothedCaptureMS == 0 ? captureMS : smoothedCaptureMS * 0.9 + captureMS * 0.1
        let outputMaximum = destinations.compactMap { $0.window?.screen.maximumFramesPerSecond }.max() ?? 60
        let sourceMaximum = window.screen.maximumFramesPerSecond
        supportedFPS = min(sourceMaximum, outputMaximum)
        let now = ProcessInfo.processInfo.systemUptime
        if now - lastPacingUpdate >= 2 {
            lastPacingUpdate = now
            let nextFPS: Float = prioritizesPresenter ? 2 : PresenterCapturePacing.target(sourceMaximum: sourceMaximum, outputMaximum: outputMaximum, captureMS: smoothedCaptureMS)
            if nextFPS != targetFPS {
                targetFPS = nextFPS
                link?.preferredFrameRateRange = CAFrameRateRange(minimum: min(15, targetFPS), maximum: targetFPS, preferred: targetFPS)
                diagnostics("pacing sourceMaxFPS=\(sourceMaximum) outputMaxFPS=\(outputMaximum) supportedFPS=\(supportedFPS) targetFPS=\(targetFPS) captureEMAms=\(smoothedCaptureMS)")
            }
        }
        frame = result
        let elapsed = ProcessInfo.processInfo.systemUptime - metricsStart
        if elapsed >= 5 {
            let role = window.windowScene?.session.role.rawValue ?? "none"
            diagnostics("stats backend=metal captureScope=slide-subtree presenterPriority=\(prioritizesPresenter) throttleSkips=\(throttleSkips) quietPeriodMS=\(PresenterCapturePacing.outerQuietPeriod(captureMS: smoothedCaptureMS) * 1000) supportedFPS=\(supportedFPS) targetFPS=\(targetFPS) busyDrops=\(busyDrops) inFlight=\(inFlight) gpuFrames=\(gpuFrames) gpuFailures=\(gpuFailures) meanSubmitToCompleteMS=\(gpuTotalMS / Double(max(gpuFrames, 1))) fps=\(Double(renderedFrames) / elapsed) frames=\(renderedFrames) incomplete=\(incompleteFrames) fallback=\(fallbackTicks) meanRenderMS=\(renderMilliseconds / Double(max(renderedFrames, 1))) pixels=\(result.size) destinationPixels=\(destinationPixels) sourceNativePixels=\(CGSize(width: rect.width * window.screen.scale, height: rect.height * window.screen.scale)) sourceRole=\(role) sourceLocalBounds=\(source.bounds) sourceRect=\(rect) window=\(window.bounds) outputMode=\(output.rawValue) duoRunning=\(DualDisplayCaptureKeeper.shared.isRunning) duoMode=\(DualDisplayCaptureKeeper.shared.displayMode.rawValue) externalConnected=\(ExternalDisplayCoordinator.shared.isConnected) externalMode=\(ExternalDisplayCoordinator.shared.preferredMode)")
            metricsStart = ProcessInfo.processInfo.systemUptime
            renderedFrames = 0
            throttleSkips = 0
            incompleteFrames = 0
            fallbackTicks = 0
            renderMilliseconds = 0
            busyDrops = 0
            gpuFrames = 0
            gpuTotalMS = 0
            gpuFailures = 0
        }
        report("shared bitmap pixels=\(result.size) complete=\(result.complete) outputs=\(destinations.count)")
        let targets = destinations.filter { $0.window !== window }.map { $0.metalTarget() }
        guard !targets.isEmpty else { return }
        inFlight += 1
        let expectedOutputs = targets.count
        metalRenderer.present(result, to: targets) { [weak self] milliseconds, count, success in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.inFlight -= 1
                self.gpuFrames += 1
                self.gpuTotalMS += milliseconds
                if !success || count < expectedOutputs {
                    self.gpuFailures += 1
                    self.report("Metal presentation failed success=\(success) destinations=\(count)/\(expectedOutputs)")
                }
            }
        }
    }


}

@MainActor
private final class CaptureFrameTicker: NSObject {
    weak var capture: PresenterSlideCapture?
    init(_ capture: PresenterSlideCapture) { self.capture = capture }
    @objc func tick() { capture?.tick() }
}

/// One live slide subtree: menus/toolbars outside this host cannot enter its bitmap.
struct PresenterSlideCaptureSurface<Content: View>: UIViewControllerRepresentable {
    @Environment(\.self) private var environment
    @ViewBuilder var content: () -> Content

    func makeUIViewController(context: Context) -> PresenterSlideHostController {
        PresenterSlideHostController(rootView: AnyView(content().environment(\.self, environment)))
    }
    func updateUIViewController(_ controller: PresenterSlideHostController, context: Context) {
        controller.rootView = AnyView(content().environment(\.self, environment))
        if let view = controller.viewIfLoaded, let scene = view.window?.windowScene,
           PresenterSlideCapture.supportsSource(scene) {
            PresenterSlideCapture.shared.register(view)
        }
    }
    static func dismantleUIViewController(_ controller: PresenterSlideHostController, coordinator: ()) {
        PresenterSlideCapture.shared.unregister(controller.view)
    }
    func sizeThatFits(_ proposal: ProposedViewSize, uiViewController: PresenterSlideHostController, context: Context) -> CGSize? {
        guard let width = proposal.width, let height = proposal.height else { return nil }
        return CGSize(width: width, height: height)
    }
}

final class PresenterSlideHostController: UIHostingController<AnyView> {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        safeAreaRegions = []
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let scene = view.window?.windowScene, PresenterSlideCapture.supportsSource(scene) {
            PresenterSlideCapture.shared.register(view)
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let scene = view.window?.windowScene, PresenterSlideCapture.supportsSource(scene) {
            PresenterSlideCapture.shared.register(view)
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        PresenterSlideCapture.shared.unregister(view)
    }
}

struct PresenterSlideMirrorView: View {
    @ObservedObject private var capture = PresenterSlideCapture.shared
    var body: some View {
        ZStack {
            PresenterMetalOutputView()
            if capture.output == .systemCapture, let status = capture.captureStatus {
                Text(status).font(.headline).foregroundStyle(.white).multilineTextAlignment(.center).padding()
                    .background(.black.opacity(0.85))
            }
        }
    }
}

private struct PresenterMetalOutputView: UIViewRepresentable {
    func makeUIView(context: Context) -> PresenterSlideMirrorUIView { PresenterSlideMirrorUIView() }
    func updateUIView(_ view: PresenterSlideMirrorUIView, context: Context) {}
    static func dismantleUIView(_ view: PresenterSlideMirrorUIView, coordinator: ()) { view.stop() }
}

final class PresenterSlideMirrorUIView: UIView {
    override class var layerClass: AnyClass { CAMetalLayer.self }
    private var metalLayer: CAMetalLayer { layer as! CAMetalLayer }
    private let blankingCover = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        clipsToBounds = true
        isUserInteractionEnabled = false
        metalLayer.device = PresenterSlideCapture.shared.metalRenderer?.device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.colorspace = CGColorSpace(name: CGColorSpace.sRGB)
        metalLayer.framebufferOnly = true
        metalLayer.maximumDrawableCount = 2
        metalLayer.allowsNextDrawableTimeout = true
        // Hiding the backing CAMetalLayer also makes UIView.isHidden true.
        // Keep this output eligible for capture; blank only with a child cover.
        blankingCover.backgroundColor = .black
        blankingCover.isUserInteractionEnabled = false
        addSubview(blankingCover)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func layoutSubviews() {
        super.layoutSubviews()
        blankingCover.frame = bounds
        let scale = window?.screen.scale ?? traitCollection.displayScale
        metalLayer.contentsScale = scale
        // Full HD input is shared; cap each drawable to the same long-edge limit.
        let pixelWidth = bounds.width * scale, pixelHeight = bounds.height * scale
        let reduction = min(1, 1920 / max(1, max(pixelWidth, pixelHeight)))
        metalLayer.drawableSize = CGSize(width: max(1, floor(pixelWidth * reduction)), height: max(1, floor(pixelHeight * reduction)))
    }
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window == nil { stop() }
        else {
            setNeedsLayout()
            PresenterSlideCapture.shared.addOutput(self)
        }
    }
    func metalTarget() -> PresenterMetalRenderer.Target {
        blankingCover.isHidden = true
        return .init(layer: metalLayer)
    }
    func clearFrame() { blankingCover.isHidden = false }
    func stop() {
        clearFrame()
        PresenterSlideCapture.shared.removeOutput(self)
    }
}
#endif

#if os(iOS)
import UIKit
import QuartzCore

@MainActor
enum PresenterRenderDiagnostics {
    static func reportOutputTransport() {
        // A disabled accessory may have no scene. This inventory can only
        // describe observed scenes; it cannot prove that OS mirroring is absent.
        let sceneScreens = UIApplication.shared.connectedScenes.compactMap { ($0 as? UIWindowScene)?.screen }
        var observedScreens = Set<ObjectIdentifier>()
        let mirrored = sceneScreens.filter { observedScreens.insert(ObjectIdentifier($0)).inserted && $0.mirrored != nil }
        PresenterSlideCapture.shared.diagnostics("transport-check requested=\(ExternalDisplayCoordinator.shared.preferredMode) effective=\(ExternalDisplayCoordinator.shared.effectiveMode) mirroredSceneScreens=\(mirrored.count) sceneInventoryOnly=true captureDriverRunning=\(PresenterSlideCapture.shared.isCapturingFrames) duoRunning=\(DualDisplayCaptureKeeper.shared.isRunning)")
        for screen in mirrored {
            PresenterSlideCapture.shared.diagnostics("os-mirror screen=\(screen.bounds) pixels=\(screen.nativeBounds) source=\(screen.mirrored?.bounds ?? .zero) maximumFPS=\(screen.maximumFramesPerSecond)")
        }
    }

    /// Read public layer geometry only; no image pixels or private RealityKit APIs.
    static func reportMetalSurfaces(reason: String) {
        for scene in UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }) {
            for window in scene.windows where !window.isHidden {
                inspect(window.layer, role: scene.session.role.rawValue, reason: reason)
            }
        }
    }

    private static func inspect(_ layer: CALayer, role: String, reason: String) {
        if let metal = layer as? CAMetalLayer {
            PresenterSlideCapture.shared.diagnostics("metal-surface reason=\(reason) role=\(role) bounds=\(metal.bounds) drawablePixels=\(metal.drawableSize) scale=\(metal.contentsScale)")
        }
        for child in layer.sublayers ?? [] { inspect(child, role: role, reason: reason) }
    }
}
#endif
