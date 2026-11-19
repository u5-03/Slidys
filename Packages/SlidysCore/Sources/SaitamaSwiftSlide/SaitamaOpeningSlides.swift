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
                .background(.black)
                .excludesFromSlideTapNavigation()
#else
            Text("会場撮影はiPhone / iPadで利用できます")
#endif
        }
    }
}

#if os(iOS)
private final class AudienceCamera: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    let session = AVCaptureSession()
    private let queue = DispatchQueue(label: "Slidys.SaitamaAudienceCamera")
    private let output = AVCapturePhotoOutput()
    private var configured = false
    var captureAngle: CGFloat = 0
    @Published var photo: UIImage?
    @Published var message = "カメラを開始すると、ここに会場を表示します"
    @Published var running = false
    @Published var capturing = false

    func start() {
        Task { @MainActor in
            let allowed = await AVCaptureDevice.requestAccess(for: .video)
            guard allowed else {
                message = "カメラを利用できません。設定でアクセスを許可してください。"
                return
            }
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
                    DispatchQueue.main.async { self.running = self.session.isRunning; self.message = self.session.isRunning ? "" : "カメラを開始できませんでした" }
                } catch {
                    DispatchQueue.main.async { self.message = "カメラを開始できませんでした：\(error.localizedDescription)" }
                }
            }
        }
    }
    func stop() {
        running = false
        queue.async { self.session.stopRunning() }
    }
    func shoot() {
        guard running, !capturing else { return }
        capturing = true
        let angle = captureAngle
        queue.async {
            if let connection = self.output.connection(with: .video), connection.isVideoRotationAngleSupported(angle) {
                connection.videoRotationAngle = angle
            }
            self.output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
        }
    }
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil, let data = photo.fileDataRepresentation(), let originalImage = UIImage(data: data) else {
            DispatchQueue.main.async { self.capturing = false; self.message = "撮影できませんでした。もう一度お試しください。" }
            return
        }
        let image = originalImage.audienceWidePhoto()
        var saveMessage = ""
        do {
            let directory = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("SaitamaAudiencePhotos", isDirectory: true)
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            guard let wideData = image.jpegData(compressionQuality: 0.95) else { throw CameraError.unavailable }
            try wideData.write(to: directory.appendingPathComponent("\(UUID().uuidString).jpg"), options: .atomic)
        } catch { saveMessage = "撮影しましたが、保存できませんでした" }
        let result = saveMessage
        DispatchQueue.main.async { self.photo = image; AudiencePhotoStore.shared.photo = image; self.capturing = false; self.message = result }
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
            guard let connection = self?.previewLayer.connection else { return }
            let angle = coordinator.videoRotationAngleForHorizonLevelPreview
            if connection.isVideoRotationAngleSupported(angle) { connection.videoRotationAngle = angle }
        }
        captureObservation = coordinator.observe(\.videoRotationAngleForHorizonLevelCapture, options: [.initial, .new]) { [weak self] coordinator, _ in
            self?.onCaptureAngle?(coordinator.videoRotationAngleForHorizonLevelCapture)
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
private struct AudienceCameraView: View {
    @StateObject private var camera: AudienceCamera
    init(camera: AudienceCamera = AudienceCamera()) {
        _camera = StateObject(wrappedValue: camera)
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
            .background(.black)
            // Mount the actual AVCaptureVideoPreviewLayer without requesting camera access.
            .onAppear { camera.running = true }
    }
}

#Preview("カメラプレビュー表示中の配置") {
    SlidePreview { AudienceCameraRunningLayoutPreview() }
        .slideTheme(CustomSlideTheme(showSlideIndex: false, listTextStyle: .large))
}
#endif
