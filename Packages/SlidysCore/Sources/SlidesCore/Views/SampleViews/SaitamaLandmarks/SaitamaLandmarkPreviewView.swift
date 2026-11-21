import RealityKit
import SwiftUI
import simd

/// A reusable inspection/quiz page. Selection recreates the scene and resets its transforms.
public struct SaitamaLandmarkPreviewView: View {
    @State private var selected: SaitamaLandmark = .gyodaTower

    public init() {}

    public var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Saitama 3D Quiz").font(.title2.bold())
                    Text("この建物はどこでしょう？")
                        .font(.subheadline)
                }
                Spacer()
            }
            .padding(.trailing, 42) // Leave room for the Demo page's close button.
            Picker("建物", selection: $selected) {
                ForEach(Array(SaitamaLandmark.allCases.enumerated()), id: \.element.id) { index, item in
                    Text("第\(index + 1)問").tag(item)
                }
            }
            .pickerStyle(.segmented)
            LandmarkInspectionView(landmark: selected)
                .id(selected)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            Text("写真を参考にSwiftで生成した簡略モデルです。裏側・細部は推定です。")
                .font(.caption).foregroundStyle(.secondary)
        }
        .padding(20)
        .background(Color(red: 0.94, green: 0.94, blue: 0.91))
        .foregroundStyle(Color(red: 0.17, green: 0.22, blue: 0.23))
        .preferredColorScheme(.light)

    }
}

private struct LandmarkInspectionView: View {
    let landmark: SaitamaLandmark
    @State private var pivot: Entity?
    @State private var camera: PerspectiveCamera?
    @State private var rotation = initialRotation
    @State private var previousDrag: CGSize = .zero
    @State private var zoom: Float = 1
    @State private var pinchStart: Float?
    @State private var errorMessage: String?
    @State private var triangles = 0

    private static var initialRotation: simd_quatf {
        simd_quatf(angle: -.pi / 7, axis: [0, 1, 0]) * simd_quatf(angle: .pi / 18, axis: [1, 0, 0])
    }

    var body: some View {
        VStack(spacing: 8) {
            GeometryReader { geometry in
                scene(size: geometry.size)
                    .overlay {
                        if let errorMessage {
                            ContentUnavailableView("モデルを生成できませんでした", systemImage: "exclamationmark.triangle",
                                                   description: Text(errorMessage))
                        } else if pivot == nil { ProgressView("メッシュを生成中…") }
                    }
                    .onChange(of: geometry.size) { _, size in fitCamera(size) }
            }
            HStack(spacing: 12) {
                Button { zoom = max(0.5, zoom - 0.2); applyZoom() } label: {
                    Image(systemName: "minus.magnifyingglass")
                }.accessibilityLabel("縮小")
                Slider(value: $zoom, in: 0.5...2.5)
                    .frame(maxWidth: 220)
                    .accessibilityLabel("モデルの拡大率")
                    .onChange(of: zoom) { _, _ in applyZoom() }
                Button { zoom = min(2.5, zoom + 0.2); applyZoom() } label: {
                    Image(systemName: "plus.magnifyingglass")
                }.accessibilityLabel("拡大")
                Button("リセット", systemImage: "arrow.counterclockwise") { reset() }
            }
            .buttonStyle(.bordered)
            .padding(.horizontal, 12)
            HStack {
                Button("左へ回転", systemImage: "arrow.uturn.left") { rotate(by: -.pi / 6, axis: [0, 1, 0]) }
                Button("右へ回転", systemImage: "arrow.uturn.right") { rotate(by: .pi / 6, axis: [0, 1, 0]) }
                Button("上から見る", systemImage: "arrow.down.right") { rotate(by: .pi / 8, axis: [1, 0, 0]) }
            }
            .buttonStyle(.bordered)
            Text("ドラッグで回転 · ピンチで拡大縮小 · \(triangles.formatted()) triangles")
                .font(.caption).foregroundStyle(.secondary).padding(.bottom, 12)
        }
        .background(Color(red: 0.84, green: 0.87, blue: 0.87))
    }

    private func scene(size: CGSize) -> some View {
        RealityView { content in
#if !os(visionOS)
            content.camera = .virtual
            let lens = PerspectiveCamera()
            lens.camera.fieldOfViewInDegrees = 36
            camera = lens
            content.add(lens)
#endif
            for (position, intensity): (SIMD3<Float>, Float) in [
                ([-3, 4, 5], 1600), ([4, 1, 2], 700), ([0, 3, -4], 1100)
            ] {
                let light = DirectionalLight()
                light.light.intensity = landmark == .kadokawaMuseum && intensity != 1600 ? intensity * 0.18 : intensity
                if landmark == .kadokawaMuseum && intensity == 1600 {
                    light.shadow = .init()
                }
                light.look(at: .zero, from: position, relativeTo: nil)
                content.add(light)
            }
            do {
                let model = try SaitamaLandmarkModel.make(landmark)
                try Task.checkCancellation()
                let anchor = Entity()
                anchor.addChild(model.root)
                anchor.orientation = rotation
                anchor.scale = .init(repeating: zoom)
                content.add(anchor)
                pivot = anchor
                triangles = model.triangleCount
                fitCamera(size)
            } catch is CancellationError {
                // Closing or switching models during creation cancels this scene.
            } catch { errorMessage = error.localizedDescription }
        }
        .gesture(DragGesture().targetedToAnyEntity().onChanged { value in
            let dx = Float(value.translation.width - previousDrag.width)
            let dy = Float(value.translation.height - previousDrag.height)
            previousDrag = value.translation
            let yaw = simd_quatf(angle: dx * 0.008, axis: [0, 1, 0])
            let pitch = simd_quatf(angle: dy * 0.008, axis: [1, 0, 0])
            rotation = simd_normalize(yaw * pitch * rotation)
            pivot?.orientation = rotation
        }.onEnded { _ in previousDrag = .zero })
        .simultaneousGesture(MagnifyGesture().onChanged { value in
            if pinchStart == nil { pinchStart = zoom }
            zoom = min(2.5, max(0.5, (pinchStart ?? zoom) * Float(value.magnification)))
            pivot?.scale = .init(repeating: zoom)
        }.onEnded { _ in pinchStart = nil })
        .accessibilityLabel("回転・拡大縮小できる埼玉の建物の3Dモデル")
    }

    private func fitCamera(_ size: CGSize) {
        guard size.width > 0, size.height > 0 else { return }
        let halfAngle = atan(tan(Float.pi / 10) * min(1, Float(size.width / size.height)))
        camera?.position = [0, 0, 1.12 / sin(halfAngle)]
    }
    private func rotate(by angle: Float, axis: SIMD3<Float>) {
        rotation = simd_normalize(simd_quatf(angle: angle, axis: axis) * rotation)
        pivot?.orientation = rotation
    }
    private func applyZoom() {
        pivot?.scale = .init(repeating: zoom)
    }
    private func reset() {
        zoom = 1; pinchStart = nil; previousDrag = .zero
        rotation = Self.initialRotation
        pivot?.orientation = rotation
        pivot?.scale = .one
    }
}

#Preview {
    SaitamaLandmarkPreviewView()
}
