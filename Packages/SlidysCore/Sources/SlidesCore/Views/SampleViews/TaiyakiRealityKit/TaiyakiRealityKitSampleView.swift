import RealityKit
import SwiftUI
import simd

struct TaiyakiRealityKitSampleView: View {
    @State private var pivot: Entity?
    @State private var camera: PerspectiveCamera?
    @State private var rotation = simd_quatf(angle: 0, axis: SIMD3<Float>(0, 1, 0))
    @State private var lastDrag: CGSize = .zero
    @State private var zoom: Float = 1
    @State private var zoomAtStart: Float = 1
    @State private var radius: Float = 0.25
    @State private var statistics: String?
    @State private var errorMessage: String?
    @State private var selectedAngle = TaiyakiInspectionAngle.front

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Procedural Taiyaki")
                        .font(.title2.weight(.semibold))
                    Text("たい焼きのかたちを、Swiftから。")
                        .font(.subheadline).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24).padding(.top, 28).padding(.bottom, 8)

                GeometryReader { viewport in
                    realityView(size: viewport.size)
                        .overlay {
                            if let errorMessage {
                                ContentUnavailableView("生成できませんでした", systemImage: "exclamationmark.triangle",
                                                       description: Text(errorMessage))
                            } else if pivot == nil {
                                ProgressView("たい焼きを焼いています…")
                            }
                        }
                        .onChange(of: viewport.size) { _, size in fitCamera(size) }
                }

                VStack(spacing: 17) {
                    Text("ドラッグで回転 · ピンチで拡大")
                        .font(.footnote).foregroundStyle(.secondary)
                    Picker("表示方向", selection: $selectedAngle) {
                        ForEach(TaiyakiInspectionAngle.allCases) { angle in
                            Text(angle.rawValue).tag(angle)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("taiyaki.inspectionAngle")
                    HStack {
                        Text(statistics ?? "メッシュを生成中")
                            .font(.caption.monospacedDigit()).foregroundStyle(.secondary)
                        Spacer()
                        Button("正面にリセット", systemImage: "arrow.counterclockwise") { reset() }
                            .font(.subheadline.weight(.medium))
                            .accessibilityIdentifier("taiyaki.reset")
                    }
                }
                .padding(.horizontal, 24).padding(.top, 8).padding(.bottom, 24)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color(red: 0.91, green: 0.90, blue: 0.87).ignoresSafeArea())
            .foregroundStyle(Color(red: 0.25, green: 0.21, blue: 0.17))
        }
        .onChange(of: selectedAngle) { _, angle in
            rotation = angle.rotation
            pivot?.orientation = rotation
        }
    }

    private func realityView(size: CGSize) -> some View {
        RealityView { content in
#if !os(visionOS)
            content.camera = .virtual
            let perspective = PerspectiveCamera()
            perspective.camera.fieldOfViewInDegrees = 36
            camera = perspective
            content.add(perspective)
#endif
            // Broad, shadow-free illumination makes both sides easy to inspect.
            for (position, intensity): (SIMD3<Float>, Float) in [
                ([-1.8, 2.4, 3], 1800), ([2.2, 0.3, 2], 1150),
                ([0.2, 1.5, -3], 1850), ([-1, -2, -1], 700)
            ] {
                let light = DirectionalLight()
                light.light.intensity = intensity
                light.look(at: .zero, from: position, relativeTo: nil)
                content.add(light)
            }
            do {
                let result = try await TaiyakiEntity.make()
                try Task.checkCancellation()
                let newPivot = Entity()
                newPivot.name = "TaiyakiInspectionPivot"
                newPivot.addChild(result.root)
                newPivot.orientation = rotation
                content.add(newPivot)
                pivot = newPivot
                radius = simd_length(result.bounds.extents) * 0.5
                statistics = "\(result.triangleCount.formatted()) tris · \(result.modelCount) meshes"
                fitCamera(size)
            } catch is CancellationError {
                // The user closed the sample while it was being generated.
            } catch {
                errorMessage = error.localizedDescription
            }
        }
        .gesture(DragGesture().targetedToAnyEntity().onChanged { value in
            let delta = CGSize(width: value.translation.width - lastDrag.width,
                               height: value.translation.height - lastDrag.height)
            lastDrag = value.translation
            let yaw = simd_quatf(angle: Float(delta.width) * 0.010, axis: [0, 1, 0])
            let pitch = simd_quatf(angle: Float(delta.height) * 0.010, axis: [1, 0, 0])
            rotation = simd_normalize(yaw * pitch * rotation)
            pivot?.orientation = rotation
        }.onEnded { _ in lastDrag = .zero })
        .simultaneousGesture(MagnifyGesture().onChanged { value in
            zoom = min(2.6, max(0.55, zoomAtStart * Float(value.magnification)))
            pivot?.scale = .init(repeating: zoom)
        }.onEnded { _ in zoomAtStart = zoom })
        .accessibilityLabel("手続き的に生成した3Dたい焼き")
    }

    private func fitCamera(_ size: CGSize) {
        guard size.width > 0, size.height > 0 else { return }
        let aspect = Float(size.width / size.height)
        let halfAngle = atan(tan(Float.pi / 10) * min(1, aspect))
        camera?.position = [0, 0, radius / sin(halfAngle) * 1.10]
    }

    private func reset() {
        selectedAngle = .front
        rotation = TaiyakiInspectionAngle.front.rotation
        zoom = 1; zoomAtStart = 1; lastDrag = .zero
        pivot?.orientation = rotation
        pivot?.scale = .one
    }
}

private enum TaiyakiInspectionAngle: String, CaseIterable, Identifiable {
    case front = "正面"
    case oblique = "斜め"
    case side = "側面"
    case back = "背面"
    var id: Self { self }
    var rotation: simd_quatf {
        switch self {
        case .front: simd_quatf(angle: 0, axis: [0, 1, 0])
        case .oblique: simd_quatf(angle: -.pi / 4, axis: [0, 1, 0]) * simd_quatf(angle: .pi / 18, axis: [1, 0, 0])
        case .side: simd_quatf(angle: -.pi / 2, axis: [0, 1, 0])
        case .back: simd_quatf(angle: .pi, axis: [0, 1, 0])
        }
    }
}

#Preview {
    TaiyakiRealityKitSampleView()
}

