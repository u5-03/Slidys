import RealityKit
import SwiftUI
import simd
import Sugiy

public struct TaiyakiRealityKitSampleView: View {
    /// 表示するたい焼きモデルの種類。
    /// ビューア(背景・ライト・カメラ・操作)は共通で、モデルの出どころだけを切り替える。
    public enum ModelSource {
        /// Swiftコードで手続き的に生成したたい焼き(Astra製サンプル)
        case procedural
        /// Blenderでモデリングした Taiyaki.usdz(Sugiyパッケージ)
        case blenderUSDZ
    }

    @Environment(\.isSlideThumbnail) private var isSlideThumbnail
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

    /// 表示するモデル(既定はSwift手続き生成)
    private let source: ModelSource
    /// タイトル・操作ヒント・メッシュ統計などの補足テキストを表示するか(スライド埋め込み時はfalse)
    private let showsInfoTexts: Bool
    /// コントロール(表示方向タブ・リセットボタン)の文字/余白の倍率
    private let fontScale: CGFloat
    /// オブジェクトの表示倍率(カメラ距離を縮めて大きく見せる)
    private let modelScale: Float

    private let textColor = Color(red: 0.25, green: 0.21, blue: 0.17)

    public init(
        source: ModelSource = .procedural,
        showsInfoTexts: Bool = true,
        fontScale: CGFloat = 1,
        modelScale: Float = 1
    ) {
        self.source = source
        self.showsInfoTexts = showsInfoTexts
        self.fontScale = fontScale
        self.modelScale = modelScale
    }

    public var body: some View {
        // スライド一覧のサムネイルではRealityViewを起動せず、プレースホルダーだけ出す
        if isSlideThumbnail {
            ZStack {
                Color.black
                Image(systemName: "cube.transparent")
                    .font(.system(size: 160, weight: .light))
                    .foregroundStyle(.gray)
            }
        } else {
            mainContent
        }
    }

    private var mainContent: some View {
        // RealityViewを全面に敷き、コントロールは下端のオーバーレイにする
        // (コントロール分の高さもオブジェクトの表示領域として使えるようにする)
        GeometryReader { geometry in
            realityView(size: geometry.size)
                .overlay {
                    if let errorMessage {
                        ContentUnavailableView("生成できませんでした", systemImage: "exclamationmark.triangle",
                                               description: Text(errorMessage))
                    } else if pivot == nil {
                        ProgressView("たい焼きを焼いています…")
                    }
                }
                .overlay(alignment: .topLeading) {
                    if showsInfoTexts {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Procedural Taiyaki")
                                .font(.title2.weight(.semibold))
                            Text("たい焼きのかたちを、Swiftから。")
                                .font(.subheadline).foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 24).padding(.top, 28)
                    }
                }
                .overlay(alignment: .bottom) {
                    VStack(spacing: 14 * fontScale) {
                        if showsInfoTexts {
                            Text("ドラッグで回転 · ピンチで拡大")
                                .font(.footnote).foregroundStyle(.secondary)
                        }
                        anglePicker
                    }
                    .padding(.bottom, 20 * fontScale)
                }
                .overlay(alignment: .bottomTrailing) {
                    Button {
                        reset()
                    } label: {
                        Label("正面にリセット", systemImage: "arrow.counterclockwise")
                            .font(.system(size: 15 * fontScale, weight: .medium))
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("taiyaki.reset")
                    .padding(.trailing, 24).padding(.bottom, 22 * fontScale)
                }
                .overlay(alignment: .bottomLeading) {
                    if showsInfoTexts {
                        Text(statistics ?? "メッシュを生成中")
                            .font(.caption.monospacedDigit()).foregroundStyle(.secondary)
                            .padding(.leading, 24).padding(.bottom, 24)
                    }
                }
                .onChange(of: geometry.size) { _, size in fitCamera(size) }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .background(Color(red: 0.91, green: 0.90, blue: 0.87).ignoresSafeArea())
                .foregroundStyle(textColor)
        }
        .onChange(of: selectedAngle) { _, angle in
            rotation = angle.rotation
            pivot?.orientation = rotation
        }
    }

    /// 標準のsegmented Pickerはフォント指定で大きくできないため、
    /// スライド埋め込み時にも拡大できるカプセル型のカスタムタブにしている。
    private var anglePicker: some View {
        HStack(spacing: 14 * fontScale) {
            Text("表示方向")
                .font(.system(size: 13 * fontScale, weight: .semibold))
                .foregroundStyle(textColor.opacity(0.7))
            HStack(spacing: 8 * fontScale) {
                ForEach(TaiyakiInspectionAngle.allCases) { angle in
                    Button {
                        selectedAngle = angle
                    } label: {
                        Text(angle.rawValue)
                            .font(.system(size: 16 * fontScale, weight: .semibold))
                            .foregroundStyle(selectedAngle == angle ? Color.white : textColor)
                            .padding(.horizontal, 16 * fontScale)
                            .padding(.vertical, 7 * fontScale)
                            .background(
                                Capsule().fill(selectedAngle == angle ? textColor : textColor.opacity(0.12))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .accessibilityIdentifier("taiyaki.inspectionAngle")
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
                let loaded = try await loadModel()
                try Task.checkCancellation()
                let newPivot = Entity()
                newPivot.name = "TaiyakiInspectionPivot"
                newPivot.addChild(loaded.root)
                newPivot.orientation = rotation
                content.add(newPivot)
                pivot = newPivot
                radius = simd_length(loaded.boundsExtents) * 0.5
                statistics = loaded.statistics
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

    /// source に応じてたい焼きモデルを読み込む(どちらも原点中心に整えて返す)。
    private func loadModel() async throws -> (root: Entity, boundsExtents: SIMD3<Float>, statistics: String?) {
        switch source {
        case .procedural:
            let result = try await TaiyakiEntity.make()
            return (
                result.root,
                result.bounds.extents,
                "\(result.triangleCount.formatted()) tris · \(result.modelCount) meshes"
            )
        case .blenderUSDZ:
            let scene = try await Entity(named: "Taiyaki", in: sugiyBundle)
            // 具材は複数内包されているため、あんこだけを表示する
            for filling in TaiyakiFilling.allCases {
                scene.findEntity(named: filling.rawValue)?.isEnabled = (filling == .redBeans)
            }
            let bounds = scene.visualBounds(relativeTo: nil)
            scene.position = -bounds.center
            scene.generateCollisionShapes(recursive: true)
            scene.components.set(InputTargetComponent())
            return (scene, bounds.extents, nil)
        }
    }

    private func fitCamera(_ size: CGSize) {
        guard size.width > 0, size.height > 0 else { return }
        let aspect = Float(size.width / size.height)
        let halfAngle = atan(tan(Float.pi / 10) * min(1, aspect))
        let distance = radius / sin(halfAngle) * 1.10 / modelScale
        // 下端のコントロールに被らないよう、カメラを少し下げてオブジェクトを画面のやや上に寄せる
        // (画面半分の高さに対する割合。垂直半画角はfov 36°の半分 = π/10)
        let verticalShift = distance * tan(Float.pi / 10) * 0.18
        camera?.position = [0, -verticalShift, distance]
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
