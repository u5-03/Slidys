import SwiftUI

public enum PresenterSlideOutput: String, CaseIterable, Identifiable {
    case independent
    case capture
    public var id: String { rawValue }
    public var title: String {
        switch self {
        case .independent: "通常表示（従来）"
        case .capture: "手元の操作を映す"
        }
    }
}

#if os(iOS)
import UIKit
import OSLog
import Darwin

private let presenterCaptureLogger = Logger(subsystem: "Slidys", category: "PresenterCapture")

/// One producer for all output displays. Only a bounded bitmap is retained, never a
/// chain of render-server snapshot views containing the entire source window.
@MainActor
final class PresenterSlideCapture: ObservableObject {
    static let shared = PresenterSlideCapture()
    @Published var output: PresenterSlideOutput = .independent {
        didSet { diagnostics("mode old=\(oldValue.rawValue) new=\(output.rawValue)") }
    }
    private final class SourceReference {
        weak var view: UIView?
        init(_ view: UIView) { self.view = view }
    }
    private var sources: [SourceReference] = []
    private let outputs = NSHashTable<PresenterSlideMirrorUIView>.weakObjects()
    private var link: CADisplayLink?
    private var watchdog: Timer?
    private var ticker: CaptureFrameTicker?
    private var lastTick: TimeInterval = 0
    private var lastReport = ""
    private var frame: UIImage?
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
        let imageBytes = frame?.cgImage.map { $0.bytesPerRow * $0.height } ?? 0
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
        guard !sources.contains(where: { $0.view === view }) else { return }
        sources.append(SourceReference(view))
        clearFrame()
        diagnostics("source registered")
    }
    func unregister(_ view: UIView) {
        sources.removeAll { $0.view == nil || $0.view === view }
        if source == nil { clearFrame() }
        diagnostics("source unregistered")
    }
    func addOutput(_ view: PresenterSlideMirrorUIView) {
        outputs.add(view)
        view.receive(frame)
        startIfNeeded()
        diagnostics("output attached")
    }
    func removeOutput(_ view: PresenterSlideMirrorUIView) {
        outputs.remove(view)
        if outputs.allObjects.isEmpty { stopDriver() }
        diagnostics("output detached")
    }

    private func startIfNeeded() {
        guard link == nil, !outputs.allObjects.isEmpty else { return }
        metricsStart = ProcessInfo.processInfo.systemUptime
        renderedFrames = 0
        incompleteFrames = 0
        fallbackTicks = 0
        renderMilliseconds = 0
        diagnostics("driver start targetFPS=15 maximumPixels=1920 maximumArea=2073600")
        let ticker = CaptureFrameTicker(self)
        self.ticker = ticker
        let link = CADisplayLink(target: ticker, selector: #selector(CaptureFrameTicker.tick))
        link.preferredFrameRateRange = CAFrameRateRange(minimum: 10, maximum: 15, preferred: 15)
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
        if wasRunning { diagnostics("driver stopped frame-released") }
    }
    private func clearFrame() {
        frame = nil
        outputs.allObjects.forEach { $0.receive(nil) }
    }
    private func report(_ message: String) {
        guard lastReport != message else { return }
        lastReport = message
        presenterCaptureLogger.notice("[PresenterCapture] \(message, privacy: .public)")
    }

    func tick() {
        lastTick = Date.timeIntervalSinceReferenceDate
        let destinations = outputs.allObjects.filter { $0.window != nil && !$0.isHidden }
        guard !destinations.isEmpty else { stopDriver(); return }
        guard let source, let window = source.window else {
            report("waiting for visible slide source")
            clearFrame()
            return
        }
        let rect = source.convert(source.bounds, to: window)
        guard PresenterSnapshotLayout.make(source: rect, screen: window.bounds, output: CGRect(origin: .zero, size: rect.size)) != nil else {
            report("waiting for source layout source=\(rect) window=\(window.bounds)")
            clearFrame()
            return
        }
        // Resolve each destination in physical pixels; render only the largest needed image.
        let destinationPixels = destinations.filter { $0.window !== window }.compactMap { destination -> CGSize? in
            guard let destinationWindow = destination.window else { return nil }
            let scale = destinationWindow.screen.scale
            return CGSize(width: destination.bounds.width * scale, height: destination.bounds.height * scale)
        }
        guard let pixelSize = PresenterCaptureResolution.pixels(source: rect.size, destinations: destinationPixels) else { return }
        let renderStart = ProcessInfo.processInfo.systemUptime
        guard let result = autoreleasepool(invoking: { Self.render(source: source, pixelSize: pixelSize) }) else {
            report("source bitmap unavailable")
            return
        }
        renderedFrames += 1
        if !result.complete { incompleteFrames += 1 }
        renderMilliseconds += (ProcessInfo.processInfo.systemUptime - renderStart) * 1000
        frame = result.image
        let elapsed = ProcessInfo.processInfo.systemUptime - metricsStart
        if elapsed >= 5 {
            let role = window.windowScene?.session.role.rawValue ?? "none"
            diagnostics("stats captureScope=slide-subtree fps=\(Double(renderedFrames) / elapsed) frames=\(renderedFrames) incomplete=\(incompleteFrames) fallback=\(fallbackTicks) meanRenderMS=\(renderMilliseconds / Double(max(renderedFrames, 1))) pixels=\(result.image.size) destinationPixels=\(destinationPixels) sourceNativePixels=\(CGSize(width: rect.width * window.screen.scale, height: rect.height * window.screen.scale)) sourceRole=\(role) sourceRect=\(rect) window=\(window.bounds) outputMode=\(output.rawValue) duoRunning=\(DualDisplayCaptureKeeper.shared.isRunning) duoMode=\(DualDisplayCaptureKeeper.shared.displayMode.rawValue) externalConnected=\(ExternalDisplayCoordinator.shared.isConnected) externalMode=\(ExternalDisplayCoordinator.shared.preferredMode)")
            metricsStart = ProcessInfo.processInfo.systemUptime
            renderedFrames = 0
            incompleteFrames = 0
            fallbackTicks = 0
            renderMilliseconds = 0
        }
        report("shared bitmap pixels=\(result.image.size) complete=\(result.complete) outputs=\(destinations.count)")
        for destination in destinations where destination.window !== window {
            destination.receive(result.image)
        }
    }

    /// Source cropping happens while rendering; output resolution never follows a
    /// 3x full-screen backing surface. Both HDMI and Duo reuse this exact image.
    static func render(source: UIView, pixelSize: CGSize) -> (image: UIImage, complete: Bool)? {
        let sourceRect = source.bounds
        guard sourceRect.width > 1, sourceRect.height > 1 else { return nil }
        guard pixelSize.width > 0, pixelSize.height > 0,
              max(pixelSize.width, pixelSize.height) <= maximumPixelDimension,
              pixelSize.width * pixelSize.height <= 1920 * 1080 else { return nil }
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true
        format.preferredRange = .standard
        var complete = false
        let image = UIGraphicsImageRenderer(size: pixelSize, format: format).image { context in
            UIColor.black.setFill()
            context.fill(CGRect(origin: .zero, size: pixelSize))
            context.cgContext.scaleBy(x: pixelSize.width / sourceRect.width, y: pixelSize.height / sourceRect.height)
            context.cgContext.translateBy(x: -sourceRect.minX, y: -sourceRect.minY)
            // Never force a synchronous update of the RealityView/Metal surface.
            complete = source.drawHierarchy(in: source.bounds, afterScreenUpdates: false)
        }
        return (image, complete)
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

struct PresenterSlideMirrorView: UIViewRepresentable {
    func makeUIView(context: Context) -> PresenterSlideMirrorUIView { PresenterSlideMirrorUIView() }
    func updateUIView(_ view: PresenterSlideMirrorUIView, context: Context) {}
    static func dismantleUIView(_ view: PresenterSlideMirrorUIView, coordinator: ()) { view.stop() }
}

final class PresenterSlideMirrorUIView: UIView {
    private let imageView = UIImageView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        clipsToBounds = true
        isUserInteractionEnabled = false
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
    }
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window == nil { stop() }
        else { PresenterSlideCapture.shared.addOutput(self) }
    }
    func receive(_ image: UIImage?) { imageView.image = image }
    func stop() {
        imageView.image = nil
        PresenterSlideCapture.shared.removeOutput(self)
    }
}
#endif
