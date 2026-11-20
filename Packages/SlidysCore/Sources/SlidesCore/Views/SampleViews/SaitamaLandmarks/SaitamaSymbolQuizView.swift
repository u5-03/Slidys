import Observation
import SlideKit
import RealityKit
import SummonEffectAssets
import SwiftUI
import YugiohCardEffect
import simd

/// Presentation state is shared by the presenter and external-display renderers.
/// RealityKit entities belong to each renderer and are never shared between scenes.
@MainActor @Observable
final class SaitamaQuizSession {
    static let shared = SaitamaQuizSession()
    enum Phase { case choosing, focusing, summoning, inspecting, returning }
    var selected: SaitamaLandmark?
    var selectionID = UUID()
    var phase = Phase.choosing
    var isBack = true
    var sceneReady = false
    var errorMessage: String?
    var zoom: Float = 1
    var rotation = initialRotation
    private var sequence: Task<Void, Never>?

    static var initialRotation: simd_quatf {
        simd_quatf(angle: -.pi / 7, axis: [0, 1, 0]) * simd_quatf(angle: .pi / 18, axis: [1, 0, 0])
    }

    func select(_ landmark: SaitamaLandmark, reduceMotion: Bool) {
        guard selected == nil else { return }
        sequence?.cancel()
        selectionID = UUID()
        sceneReady = false
        errorMessage = nil
        zoom = 1
        rotation = Self.initialRotation
        isBack = true
        withAnimation(reduceMotion ? nil : .spring(response: 0.6, dampingFraction: 0.88)) {
            selected = landmark
            phase = .focusing
        }
        sequence = Task { @MainActor in
            do {
                try await Task.sleep(for: .milliseconds(reduceMotion ? 1 : 160))
                withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.55)) { isBack = false }
                try await Task.sleep(for: .milliseconds(reduceMotion ? 1 : 650))
                // Do not summon an empty card while its mesh or particle asset is loading.
                while !sceneReady && errorMessage == nil {
                    try await Task.sleep(for: .milliseconds(40))
                }
                guard errorMessage == nil else { return }
                withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.8)) { phase = .summoning }
                try await Task.sleep(for: .milliseconds(reduceMotion ? 1 : 1500))
                phase = .inspecting
            } catch { /* Changing cards or leaving the slide cancels the sequence. */ }
        }
    }

    func returnToCards(reduceMotion: Bool) {
        guard selected != nil, phase != .returning else { return }
        sequence?.cancel()
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.35)) {
            isBack = true
            phase = .returning
        }
        sequence = Task { @MainActor in
            do {
                try await Task.sleep(for: .milliseconds(reduceMotion ? 1 : 400))
                withAnimation(reduceMotion ? nil : .spring(response: 0.55, dampingFraction: 0.9)) {
                    self.selected = nil
                    phase = .choosing
                }
            } catch { }
        }
    }

    func resetTransform() { zoom = 1; rotation = Self.initialRotation }

    func stopPresentation() {
        sequence?.cancel()
        sequence = nil
        selected = nil
        phase = .choosing
    }
}

public struct SaitamaSymbolQuizView: View {
    @State private var session = SaitamaQuizSession.shared
    @Namespace private var cards
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.isSlideThumbnail) private var isThumbnail

    public init() {}

    public var body: some View {
        GeometryReader { geometry in
            let unit = max(0.5, geometry.size.width / 1200)
            ZStack {
                Color.slideBackgroundColor
                if isThumbnail || session.selected == nil {
                    cardSelection(size: geometry.size, unit: unit)
                } else if let selected = session.selected {
                    focusedCard(selected, size: geometry.size, unit: unit)
                }
            }
            .foregroundStyle(.white)
            .clipShape(Rectangle())
        }
        .excludesFromSlideTapNavigation()
    }

    private func cardSelection(size: CGSize, unit: CGFloat) -> some View {
        VStack(spacing: 22 * unit) {
            VStack(spacing: 8 * unit) {
                Text("Saitama Symbol Quiz").font(.system(size: 48 * unit, weight: .bold))
                Text("カードを選んで、埼玉のシンボルを召喚しよう")
                    .font(.system(size: 22 * unit)).foregroundStyle(.white.opacity(0.7))
            }
            HStack(spacing: 38 * unit) {
                ForEach(Array(SaitamaLandmark.allCases.enumerated()), id: \.element.id) { index, landmark in
                    VStack(spacing: 12 * unit) {
                        Button {
                            session.select(landmark, reduceMotion: reduceMotion)
                        } label: {
                            QuizCard(index: index, angle: 180)
                                .matchedGeometryEffect(id: landmark.id, in: cards)
                                .shadow(color: .cyan.opacity(0.16), radius: 18 * unit)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("第\(index + 1)問のカードを選ぶ")
                        .disabled(isThumbnail)
                        Text("第\(index + 1)問")
                            .font(.system(size: 24 * unit, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    .frame(width: min(size.width * 0.235, size.height * 0.40))
                }
            }
        }
        .padding(30 * unit)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func focusedCard(_ landmark: SaitamaLandmark, size: CGSize, unit: CGFloat) -> some View {
        let onFloor = session.phase == .summoning || session.phase == .inspecting
        let index = SaitamaLandmark.allCases.firstIndex(of: landmark) ?? 0
        let cardHeight = size.height * (onFloor ? 0.65 : 0.83)
        let cardWidth = min(cardHeight * 590 / 860, size.width * 0.72)
        return ZStack {
            QuizCard(index: index, angle: session.isBack ? 180 : 0)
                .frame(width: cardWidth, height: cardHeight)
                .matchedGeometryEffect(id: landmark.id, in: cards)
                .rotation3DEffect(.degrees(onFloor ? 68 : 0), axis: (1, 0, 0), perspective: 0.4)
                .opacity(onFloor ? 0.65 : 1)
                .position(x: size.width / 2, y: size.height * (onFloor ? 0.79 : 0.50))
                .allowsHitTesting(false)

            SaitamaSummonedScene(landmark: landmark, session: session, reduceMotion: reduceMotion)
                .id(session.selectionID)
                .allowsHitTesting(session.phase == .inspecting)

            if session.phase == .summoning, !reduceMotion {
                SummonBoardEffectView(
                    card: .sample,
                    normalizedSourceRect: CGRect(x: 0.39, y: 0.66, width: 0.22, height: 0.17),
                    animationID: session.selectionID,
                    boardInset: 0, showsBoardBackground: false, showsCard: false,
                    clipsLinesToBounds: true, topLineSourceMode: .topEdge
                )
                .allowsHitTesting(false)
            }

            VStack(spacing: 12 * unit) {
                HStack {
                    VStack(alignment: .leading, spacing: 5 * unit) {
                        Text("Saitama Symbol Quiz  /  第\(index + 1)問")
                            .font(.system(size: 28 * unit, weight: .bold))
                        Text("この建物はどこでしょう？")
                            .font(.system(size: 23 * unit, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    Spacer()
                    Button {
                        session.returnToCards(reduceMotion: reduceMotion)
                    } label: {
                        Label("カードを裏向きに戻す", systemImage: "rectangle.on.rectangle")
                    }
                    .accessibilityIdentifier("saitama.return")
                    .disabled(session.phase == .returning)
                }
                if let error = session.errorMessage {
                    Text("モデルを表示できませんでした\n\(error)")
                        .font(.system(size: 20 * unit)).padding().background(.black.opacity(0.85))
                }
                Spacer()
                if session.phase == .inspecting {
                    Text("ドラッグで回転・ピンチで拡大縮小")
                        .font(.system(size: 17 * unit)).foregroundStyle(.white.opacity(0.7))
                    ViewThatFits(in: .horizontal) {
                        HStack(spacing: 10 * unit) {
                            transformControls(unit: unit)
                        }
                        VStack(spacing: 10 * unit) {
                            HStack { transformControls(unit: unit) }
                        }
                    }
                    .padding(12 * unit)
                    .background(.black.opacity(0.8), in: RoundedRectangle(cornerRadius: 16 * unit))
                } else if session.errorMessage == nil {
                    Text(session.phase == .focusing ? "召喚の準備中…" :
                         (session.phase == .returning ? "カードに戻す…" : "召喚！"))
                        .font(.system(size: 28 * unit, weight: .bold))
                        .padding(14 * unit).background(.black.opacity(0.7), in: Capsule())
                }
            }
            .padding(28 * unit)
            .font(.system(size: 20 * unit, weight: .semibold))
            .buttonStyle(QuizActionButtonStyle(fontSize: 20 * unit))
            .tint(.cyan)
        }
    }

    @ViewBuilder private func transformControls(unit: CGFloat) -> some View {
        Button("左へ回転", systemImage: "rotate.left") {
            session.rotation = simd_normalize(simd_quatf(angle: -.pi / 6, axis: [0, 1, 0]) * session.rotation)
        }
        Button("右へ回転", systemImage: "rotate.right") {
            session.rotation = simd_normalize(simd_quatf(angle: .pi / 6, axis: [0, 1, 0]) * session.rotation)
        }
        Button { session.zoom = max(0.55, session.zoom - 0.2) } label: {
            Image(systemName: "minus.magnifyingglass")
        }.accessibilityLabel("縮小")
        Button { session.zoom = min(2.2, session.zoom + 0.2) } label: {
            Image(systemName: "plus.magnifyingglass")
        }.accessibilityLabel("拡大")
        Button("リセット", systemImage: "arrow.counterclockwise") { session.resetTransform() }
    }


}

/// Keep projected controls readable on macOS as well as iOS; native macOS
/// bordered buttons otherwise impose their small system-control font on slides.
private struct QuizActionButtonStyle: ButtonStyle {
    let fontSize: CGFloat
    var prominent = false
    @Environment(\.isEnabled) private var isEnabled
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: fontSize, weight: .semibold))
            .padding(.horizontal, fontSize * 0.55)
            .padding(.vertical, fontSize * 0.4)
            .foregroundStyle(prominent ? Color.black : Color.white)
            .background(prominent ? Color.cyan : Color.cyan.opacity(0.16), in: Capsule())
            .opacity(isEnabled ? (configuration.isPressed ? 0.7 : 1) : 0.4)
    }
}

/// Reuses the existing card face and original card-back artwork.
private struct QuizCard: View, Animatable {
    let index: Int
    var angle: Double
    var animatableData: Double { get { angle } set { angle = newValue } }
    private var isBack: Bool { angle > 90 && angle < 270 }

    var body: some View {
        Group {
            if isBack {
                CardBackView().rotation3DEffect(.degrees(180), axis: (0, 1, 0))
            } else {
                CardView(card: CardModel(
                    id: UUID(uuidString: "00000000-0000-0000-0000-00000000000\(index + 1)")!,
                    name: "SAITAMA SYMBOL \(index + 1)", attribute: "埼", starCount: index + 3,
                    imageType: .image(image: Image(systemName: "questionmark"), aspectRatio: 0.75),
                    imageBackgroundColor: Color(red: 0.12, green: 0.26, blue: 0.29),
                    species: "埼玉のシンボル",
                    description: "このカードに眠る建物は？\n立体を回して、名前を当てよう。",
                    attackPoint: 0, defencePoint: 0
                ))
            }
        }
        .aspectRatio(590.0 / 860.0, contentMode: .fit)
        .rotation3DEffect(.degrees(angle), axis: (0, 1, 0), perspective: 0.45)
    }
}

private struct SaitamaSummonedScene: View {
    @Environment(\.displayScale) private var displayScale
    let landmark: SaitamaLandmark
    let session: SaitamaQuizSession
    let reduceMotion: Bool
    @State private var emergence: Entity?
    @State private var pivot: Entity?
    @State private var camera: PerspectiveCamera?
    @State private var burst: SummonBurstController?
    @State private var dragTranslation = CGSize.zero
    @State private var pinchStart: Float?

    private var finalTransform: Transform {
        Transform(scale: .one, translation: [0, 0.03, 0])
    }

    var body: some View {
        GeometryReader { geometry in
            let renderScale = RealityViewRenderBudget.scale(size: geometry.size, displayScale: displayScale)
            RealityView { content in
                let selectionID = session.selectionID
#if !os(visionOS)
                content.camera = .virtual
                let lens = PerspectiveCamera()
                lens.camera.fieldOfViewInDegrees = 36
                camera = lens
                content.add(lens)
#endif
                for (position, intensity): (SIMD3<Float>, Float) in [
                    ([-3, 4, 5], 1800), ([4, 1, 2], 350), ([0, 3, -4], 500)
                ] {
                    let light = DirectionalLight()
                    light.light.intensity = intensity
                    light.look(at: .zero, from: position, relativeTo: nil)
                    content.add(light)
                }
                do {
                    let model = try SaitamaLandmarkModel.make(landmark)
                    try Task.checkCancellation()
                    let rotationRoot = Entity()
                    rotationRoot.addChild(model.root)
                    rotationRoot.orientation = session.rotation
                    let entry = Entity()
                    entry.name = "SaitamaCardEmergence"
                    entry.scale = .init(repeating: 0.001)
                    entry.position = [0, -0.85, 0]
                    entry.addChild(rotationRoot)
                    content.add(entry)
                    emergence = entry
                    pivot = rotationRoot
                    fitCamera(geometry.size)
                    let effect = await SummonBurstController.make(scale: 0.65, clipsLowerHalf: false)
                    try Task.checkCancellation()
                    guard session.selectionID == selectionID else { return }
                    if let effect {
                        effect.root.position = [0, -0.75, 0]
                        content.add(effect.root)
                        burst = effect
                    }
                    session.sceneReady = true
                    applyPhase()
                } catch is CancellationError {
                } catch {
                    guard session.selectionID == selectionID else { return }
                    session.errorMessage = error.localizedDescription
                }
            } update: { _ in
                if session.phase == .inspecting {
                    pivot?.orientation = session.rotation
                    pivot?.scale = .init(repeating: session.zoom)
                }
            }
            .onChange(of: session.phase) { _, _ in applyPhase() }
            // Explicit observation also applies button changes and the transforms
            // coming from the presenter to a separate external-display renderer.
            .onChange(of: session.rotation) { _, value in
                guard session.phase == .inspecting else { return }
                pivot?.orientation = value
            }
            .onChange(of: session.zoom) { _, value in
                guard session.phase == .inspecting else { return }
                pivot?.scale = .init(repeating: value)
            }
            .onChange(of: geometry.size) { _, size in fitCamera(size) }
            .frame(width: geometry.size.width * renderScale, height: geometry.size.height * renderScale)
            .scaleEffect(1 / renderScale)
            .frame(width: geometry.size.width, height: geometry.size.height)
            .gesture(DragGesture().targetedToAnyEntity().onChanged { value in
                guard session.phase == .inspecting else { return }
                let dx = Float(value.translation.width - dragTranslation.width)
                let dy = Float(value.translation.height - dragTranslation.height)
                dragTranslation = value.translation
                session.rotation = simd_normalize(
                    simd_quatf(angle: dx * 0.008, axis: [0, 1, 0]) *
                    simd_quatf(angle: dy * 0.008, axis: [1, 0, 0]) * session.rotation
                )
                pivot?.orientation = session.rotation
            }.onEnded { _ in dragTranslation = .zero })
            .simultaneousGesture(MagnifyGesture().onChanged { value in
                guard session.phase == .inspecting else { return }
                if pinchStart == nil { pinchStart = session.zoom }
                session.zoom = min(2.2, max(0.55, (pinchStart ?? 1) * Float(value.magnification)))
                pivot?.scale = .init(repeating: session.zoom)
            }.onEnded { _ in pinchStart = nil })
            .onDisappear { burst?.stop(); emergence?.stopAllAnimations(recursive: true) }
            .accessibilityLabel("回転・拡大縮小できるクイズの3Dモデル")
        }
    }

    private func applyPhase() {
        guard let emergence else { return }
        switch session.phase {
        case .summoning:
            if !reduceMotion { burst?.fire(emitDuration: 0.8) }
            emergence.move(to: finalTransform, relativeTo: nil,
                           duration: reduceMotion ? 0 : 1.25, timingFunction: .easeOut)
        case .inspecting:
            emergence.transform = finalTransform
            pivot?.orientation = session.rotation
            pivot?.scale = .init(repeating: session.zoom)
        case .returning:
            burst?.setEmitting(false)
            emergence.move(to: Transform(scale: .init(repeating: 0.001), translation: [0, -0.85, 0]),
                           relativeTo: nil, duration: reduceMotion ? 0 : 0.35, timingFunction: .easeIn)
        case .choosing, .focusing:
            break
        }
    }

    private func fitCamera(_ size: CGSize) {
        guard size.width > 0, size.height > 0 else { return }
        let halfAngle = atan(tan(Float.pi / 10) * min(1, Float(size.width / size.height)))
        camera?.position = [0, 0, 1.35 / sin(halfAngle)]
    }
}

@Slide private struct SaitamaQuizLayoutPreview: View {
    var body: some View { SaitamaSymbolQuizView() }
}

#Preview("Saitama Symbol Quiz") {
    SlidePreview { SaitamaQuizLayoutPreview() }
        .slideTheme(CustomSlideTheme(showSlideIndex: false, listTextStyle: .large))
}
