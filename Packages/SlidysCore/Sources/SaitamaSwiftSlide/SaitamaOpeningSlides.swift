import SlideKit
import SlidesCore
import SwiftUI
#if os(iOS)
import AVFoundation
import UIKit
#endif

@Slide struct SaitamaOpeningPhotoSlide: View {
    var script: String { "当日はVision Proを装着し、カードから3Dモデルを召喚するデモをしました。" }
    var transition: AnyTransition { SlideTransition.defaultTransition }
    var body: some View {
        GeometryReader { proxy in
            Image("OpeningPhoto", bundle: .module)
                .resizable().scaledToFill()
                .frame(width: proxy.size.width, height: proxy.size.height)
                .clipped()
        }
        .background(.black)
    }
}

@Slide struct SaitamaAudienceCameraSlide: View {
    var script: String { "埼玉に住んでいる方、出身の方、手を上げてください！カメラを開始して、会場を撮影します。撮影が済んだら次のスライドへ進みます。" }
    var transition: AnyTransition { SlideTransition.defaultTransition }
    var body: some View {
        Group {
#if os(iOS)
            AudienceCameraView()
                .padding(32)
                .background(Color.slideBackgroundColor)
                .excludesFromSlideTapNavigation()
#else
            Text("会場撮影はiPhone / iPadで利用できます")
#endif
        }
    }
}

#if os(iOS)
@MainActor
private final class AudienceCamera: NSObject, ObservableObject {
    private lazy var worker = AudienceCameraWorker(
        onRunning: { [weak self] running, message in
            guard let self, self.wantsRunning else { return }
            self.running = running
            self.message = message
        },
        onPhoto: { [weak self] data, message in
            guard let self else { return }
            if let data, let image = UIImage(data: data) {
                self.photo = image
                AudiencePhotoStore.shared.photo = image
            }
            self.capturing = false
            self.message = message
        }
    )
    var session: AVCaptureSession { worker.session }
    private var wantsRunning = false
    var captureAngle: CGFloat = 0
    @Published var photo: UIImage?
    @Published var message = "カメラを開始すると、ここに会場を表示します"
    @Published var running = false
    @Published var capturing = false

    func start() {
        wantsRunning = true
        Task { @MainActor in
            let allowed = await AVCaptureDevice.requestAccess(for: .video)
            guard wantsRunning else { return }
            guard allowed else {
                message = "カメラを利用できません。設定でアクセスを許可してください。"
                return
            }
            worker.start()
        }
    }
    func stop() {
        wantsRunning = false
        running = false
        worker.stop()
    }
    func shoot() {
        guard running, !capturing else { return }
        capturing = true
        worker.shoot(angle: captureAngle)
    }
}

/// AVFoundation and mutable configuration are confined to this serial queue.
/// Only Sendable values and main-actor callbacks cross back into the UI.
private final class AudienceCameraWorker: NSObject, @unchecked Sendable, AVCapturePhotoCaptureDelegate {
    let session = AVCaptureSession()
    private let queue = DispatchQueue(label: "Slidys.SaitamaAudienceCamera")
    private let output = AVCapturePhotoOutput()
    private var configured = false
    private let onRunning: @MainActor @Sendable (Bool, String) -> Void
    private let onPhoto: @MainActor @Sendable (Data?, String) -> Void

    init(onRunning: @escaping @MainActor @Sendable (Bool, String) -> Void,
         onPhoto: @escaping @MainActor @Sendable (Data?, String) -> Void) {
        self.onRunning = onRunning
        self.onPhoto = onPhoto
        super.init()
    }

    func start() {
        queue.async { [self] in
            do {
                if !configured {
                    session.beginConfiguration()
                    defer { session.commitConfiguration() }
                    session.sessionPreset = .photo
                    guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                        throw CameraError.unavailable
                    }
                    let input = try AVCaptureDeviceInput(device: device)
                    guard session.canAddInput(input), session.canAddOutput(output) else { throw CameraError.unavailable }
                    session.addInput(input)
                    session.addOutput(output)
                    configured = true
                }
                session.startRunning()
                let running = session.isRunning
                Task { @MainActor in onRunning(running, running ? "" : "カメラを開始できませんでした") }
            } catch {
                let message = "カメラを開始できませんでした：\(error.localizedDescription)"
                Task { @MainActor in onRunning(false, message) }
            }
        }
    }
    func stop() {
        queue.async { self.session.stopRunning() }
    }
    func shoot(angle: CGFloat) {
        queue.async { [self] in
            if let connection = output.connection(with: .video), connection.isVideoRotationAngleSupported(angle) {
                connection.videoRotationAngle = angle
            }
            output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
        }
    }
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil, let data = photo.fileDataRepresentation() else {
            Task { @MainActor in onPhoto(nil, "撮影できませんでした。もう一度お試しください。") }
            return
        }
        queue.async { [self] in
            guard let image = UIImage(data: data)?.audienceWidePhoto(),
                  let wideData = image.jpegData(compressionQuality: 0.95) else {
                Task { @MainActor in onPhoto(nil, "撮影できませんでした。もう一度お試しください。") }
                return
            }
            var saveMessage = ""
            do {
                let directory = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("SaitamaAudiencePhotos", isDirectory: true)
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
                try wideData.write(to: directory.appendingPathComponent("\(UUID().uuidString).jpg"), options: .atomic)
            } catch { saveMessage = "撮影しましたが、保存できませんでした" }
            let message = saveMessage
            Task { @MainActor in onPhoto(wideData, message) }
        }
    }
    private enum CameraError: Error { case unavailable }
}

private final class AudiencePreviewUIView: UIView {
    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
    var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
    private var rotationCoordinator: AVCaptureDevice.RotationCoordinator?
    private var previewObservation: NSKeyValueObservation?
    private var captureObservation: NSKeyValueObservation?
    var onCaptureAngle: ((CGFloat) -> Void)?

    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard window != nil,
              let input = previewLayer.session?.inputs.first as? AVCaptureDeviceInput else {
            previewObservation = nil
            captureObservation = nil
            rotationCoordinator = nil
            return
        }
        let coordinator = AVCaptureDevice.RotationCoordinator(device: input.device, previewLayer: previewLayer)
        rotationCoordinator = coordinator
        previewObservation = coordinator.observe(\.videoRotationAngleForHorizonLevelPreview, options: [.initial, .new]) { [weak self] coordinator, _ in
            let angle = coordinator.videoRotationAngleForHorizonLevelPreview
            Task { @MainActor [weak self] in
                guard let connection = self?.previewLayer.connection else { return }
                if connection.isVideoRotationAngleSupported(angle) { connection.videoRotationAngle = angle }
            }
        }
        captureObservation = coordinator.observe(\.videoRotationAngleForHorizonLevelCapture, options: [.initial, .new]) { [weak self] coordinator, _ in
            let angle = coordinator.videoRotationAngleForHorizonLevelCapture
            Task { @MainActor [weak self] in self?.onCaptureAngle?(angle) }
        }
    }
}
private struct AudienceCameraPreview: UIViewRepresentable {
    let camera: AudienceCamera
    func makeUIView(context: Context) -> AudiencePreviewUIView {
        let view = AudiencePreviewUIView()
        view.onCaptureAngle = { [weak camera] angle in camera?.captureAngle = angle }
        view.previewLayer.session = camera.session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }
    func updateUIView(_ view: AudiencePreviewUIView, context: Context) {}
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: AudiencePreviewUIView, context: Context) -> CGSize? {
        proposal.replacingUnspecifiedDimensions()
    }
}
@MainActor
private struct AudienceCameraView: View {
    @StateObject private var camera: AudienceCamera
    init(camera: AudienceCamera? = nil) {
        _camera = StateObject(wrappedValue: camera ?? AudienceCamera())
    }
    var body: some View {
        GeometryReader { proxy in
            let previewWidth = max(1, min(proxy.size.width, (proxy.size.height - 168) * 2))
            VStack(spacing: 20) {
            ZStack {
                Color.black
                if let photo = camera.photo {
                    Image(uiImage: photo).resizable().scaledToFit()
                } else if camera.running {
                    AudienceCameraPreview(camera: camera)
                }
            }
            .frame(width: previewWidth, height: previewWidth / 2)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 24))
            HStack(spacing: 30) {
                Spacer()
                if camera.photo != nil {
                    Button("撮り直す", systemImage: "arrow.counterclockwise") { camera.photo = nil; camera.message = "" }
                } else if camera.running {
                    Button(camera.capturing ? "撮影中…" : "撮影", systemImage: "camera.shutter.button.fill") { camera.shoot() }
                        .disabled(camera.capturing)
                } else {
                    Button("カメラを開始", systemImage: "camera.fill") { camera.start() }
                }
                Spacer()
            }
            .font(.system(size: 40, weight: .bold))
            .buttonStyle(.borderedProminent)
            Group {
                if !camera.message.isEmpty && camera.message != "カメラを開始すると、ここに会場を表示します" {
                    Text(camera.message).font(.system(size: 24)).foregroundStyle(.white)
                } else { Color.clear }
            }
            .frame(height: 48)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .onDisappear { camera.stop() }
    }
}
#endif

#Preview("冒頭の写真") { SlidePreview { SaitamaOpeningPhotoSlide() }.slideTheme(CustomSlideTheme(showSlideIndex: false, listTextStyle: .large)) }
#Preview("会場カメラ") { SlidePreview { SaitamaAudienceCameraSlide() }.slideTheme(CustomSlideTheme(showSlideIndex: false, listTextStyle: .large)) }

#if os(iOS)
@Slide private struct AudienceCameraRunningLayoutPreview: View {
    @StateObject private var camera = AudienceCamera()
    var body: some View {
        AudienceCameraView(camera: camera)
            .padding(32)
            .background(Color.slideBackgroundColor)
            // Mount the actual AVCaptureVideoPreviewLayer without requesting camera access.
            .onAppear { camera.running = true }
    }
}

#Preview("カメラプレビュー表示中の配置") {
    SlidePreview { AudienceCameraRunningLayoutPreview() }
        .slideTheme(CustomSlideTheme(showSlideIndex: false, listTextStyle: .large))
}
#endif
