#if os(iOS) && canImport(ScreenCaptureKit) && !targetEnvironment(macCatalyst)
import UIKit
@preconcurrency import ScreenCaptureKit
import CoreMedia
import CoreVideo
import OSLog

@available(iOS 27.0, *)
final class PresenterStreamPacket: @unchecked Sendable {
    let sample: CMSampleBuffer
    let streamID: ObjectIdentifier
    init(_ sample: CMSampleBuffer, stream: SCStream) {
        self.sample = sample
        streamID = ObjectIdentifier(stream)
    }
}

/// Replace queued packets, rather than accumulating tasks/pixel buffers on the UI thread.
@available(iOS 27.0, *)
private final class PresenterStreamInbox: @unchecked Sendable {
    private let lock = NSLock()
    private var latest: PresenterStreamPacket?
    private var scheduled = false
    private let handler: @MainActor @Sendable (PresenterStreamPacket) -> Void
    init(handler: @escaping @MainActor @Sendable (PresenterStreamPacket) -> Void) { self.handler = handler }
    func send(_ packet: PresenterStreamPacket) {
        lock.lock()
        latest = packet
        let schedule = !scheduled
        scheduled = true
        lock.unlock()
        if schedule {
            Task { @MainActor [self] in
                let packet = lock.withLock {
                    let value = latest
                    latest = nil
                    scheduled = false
                    return value
                }
                if let packet { handler(packet) }
            }
        }
    }
}

@available(iOS 27.0, *)
@MainActor
final class PresenterSystemCapture: NSObject, SCContentSharingPickerObserver, SCStreamOutput, SCStreamDelegate {
    private var stream: SCStream?
    private var pending = false
    private var requested = false
    private var generation = UUID()
    private var startTask: Task<Void, Never>?
    private var sourceSize = CGSize.zero
    private var sourceScale: CGFloat = 1
    private let queue = DispatchQueue(label: "Slidys.ScreenCaptureKit.frames", qos: .userInteractive)
    nonisolated private let inbox: PresenterStreamInbox
    private let status: @MainActor (String?) -> Void
    private let failure: @MainActor (String) -> Void
    private(set) var filterRect: CGRect = .zero
    private(set) var startedAt: TimeInterval?

    init(onFrame: @escaping @MainActor @Sendable (PresenterStreamPacket) -> Void,
         status: @escaping @MainActor (String?) -> Void,
         failure: @escaping @MainActor (String) -> Void) {
        inbox = PresenterStreamInbox(handler: onFrame)
        self.status = status
        self.failure = failure
        super.init()
    }

    func isCurrent(_ packet: PresenterStreamPacket) -> Bool {
        requested && stream.map { ObjectIdentifier($0) == packet.streamID } == true
    }

    func request(window: UIWindow) {
        guard !requested else { return }
        requested = true
        sourceSize = window.bounds.size
        sourceScale = window.screen.scale
        PresenterSlideCapture.shared.diagnostics("system request window=\(window.bounds) scale=\(sourceScale) sourceRole=\(window.windowScene?.session.role.rawValue ?? "none") app=\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "unknown") build=\(Bundle.main.infoDictionary?["CFBundleVersion"] ?? "unknown") os=\(ProcessInfo.processInfo.operatingSystemVersionString)")
        PresenterSlideCapture.shared.diagnostics("system requested-display screenBounds=\(window.screen.bounds) fixedBounds=\(window.screen.fixedCoordinateSpace.bounds) nativeBounds=\(window.screen.nativeBounds) maximumFPS=\(window.screen.maximumFramesPerSecond)")
        window.makeKey()
        let picker = SCContentSharingPicker.shared
        guard picker.isAvailable else { requested = false; failure("picker-unavailable"); return }
        picker.add(self)
        var configuration = SCContentSharingPickerConfiguration()
        configuration.showsMicrophoneControl = false
        configuration.showsCameraControl = false
        picker.defaultConfiguration = configuration
        picker.isActive = true
        pending = true
        status("手元の画面の共有を開始してください")
        // Apple iOS sample uses present() for full-display capture. The in-app
        // entry point repeatedly chose Duo's accessory output instead of the source.
        PresenterSlideCapture.shared.diagnostics("system picker selection=full-display revision=full-display-v1")
        picker.present()
    }

    func stop() {
        PresenterSlideCapture.shared.diagnostics("system stop requested=\(requested) streamActive=\(stream != nil)")
        requested = false
        startedAt = nil
        pending = false
        generation = UUID()
        startTask?.cancel()
        startTask = nil
        SCContentSharingPicker.shared.remove(self)
        SCContentSharingPicker.shared.isActive = false
        let old = stream
        stream = nil
        if let old { Task { try? await old.stopCapture() } }
    }

    nonisolated func contentSharingPicker(_ picker: SCContentSharingPicker, didCancelFor stream: SCStream?) {
        Task { @MainActor [weak self] in
            self?.pending = false
            // Do not immediately reopen a cancelled picker on the next monitoring tick.
            self?.status("画面共有をキャンセルしました。メニューから選び直せます")
        }
    }
    nonisolated func contentSharingPickerStartDidFailWithError(_ error: any Error) {
        let detail = error as NSError
        let message = "domain=\(detail.domain) code=\(detail.code) message=\(detail.localizedDescription)"
        Task { @MainActor [weak self] in self?.failure("picker-start-failed \(message)") }
    }
    nonisolated func contentSharingPicker(_ picker: SCContentSharingPicker, didUpdateWith filter: SCContentFilter, for stream: SCStream?) {
        // ScreenCaptureKit types are imported preconcurrency; transfer ownership to the main actor.
        Task { @MainActor [weak self] in self?.start(filter: filter) }
    }

    private func start(filter: SCContentFilter) {
        guard requested else { return }
        pending = false
        let requestID = UUID()
        generation = requestID
        filterRect = filter.contentRect
        let configuration = SCStreamConfiguration()
        configuration.width = max(1, Int(sourceSize.width * sourceScale))
        configuration.height = max(1, Int(sourceSize.height * sourceScale))
        configuration.capturesAudio = false
        // iOS does NOT expose sourceRect, pixelFormat or minimumFrameInterval.
        let old = stream
        stream = nil
        startTask?.cancel()
        startTask = Task { [weak self] in
            guard let self else { return }
            if let old { try? await old.stopCapture() }
            guard requested, generation == requestID, !Task.isCancelled else { return }
            let next = SCStream(filter: filter, configuration: configuration, delegate: self)
            do {
                try next.addStreamOutput(self, type: .screen, sampleHandlerQueue: queue)
                stream = next
                try await next.startCapture()
                guard requested, generation == requestID, !Task.isCancelled else { try? await next.stopCapture(); return }
                startedAt = ProcessInfo.processInfo.systemUptime
                status("取得元の映像を確認しています")
                PresenterSlideCapture.shared.diagnostics("system stream started filter=\(filter.contentRect) density=\(filter.pointPixelScale) requestedSize=\(sourceSize) scale=\(sourceScale)")
            } catch {
                if generation == requestID {
                    stream = nil
                    failure("stream-start-failed \(error.localizedDescription)")
                }
            }
        }
    }
    nonisolated func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
        guard type == .screen, sampleBuffer.isValid else { return }
        inbox.send(PresenterStreamPacket(sampleBuffer, stream: stream))
    }
    nonisolated func stream(_ stream: SCStream, didStopWithError error: any Error) {
        let identifier = ObjectIdentifier(stream)
        let message = error.localizedDescription
        Task { @MainActor [weak self] in
            guard let self, self.stream.map({ ObjectIdentifier($0) == identifier }) == true else { return }
            self.stream = nil
            self.failure("stream-stopped \(message)")
        }
    }
}
#endif
