//
//  TaiyakiFocusView.swift
//  SlidysCore
//
//  Created by Yugo Sugiyama on 2026/08/12.
//

import SwiftUI
import RealityKit
import simd
import Sugiy

/// たい焼きモデルの部位アンカー。rkassets内のAnchor_*エンティティ名に対応する
enum TaiyakiPart: String, CaseIterable, Identifiable {
    case eye = "Anchor_Eye"
    case mouth = "Anchor_Mouth"
    case tail = "Anchor_Tail"
    case dorsalFin = "Anchor_DorsalFin"
    case filling = "Anchor_Filling"
    case logo = "Anchor_Logo"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .eye: "つぶらな瞳"
        case .mouth: "小さな口"
        case .tail: "カリカリの尾びれ"
        case .dorsalFin: "背びれの型押し"
        case .filling: "あふれる具材"
        case .logo: "Sugiyの焼印"
        }
    }

    var shortDescription: String {
        switch self {
        case .eye: "表情を決める焼き目"
        case .mouth: "ちょこんと結んだ口元"
        case .tail: "薄焼きで香ばしい人気部位"
        case .dorsalFin: "型の筋が並ぶ背中"
        case .filling: "4種類から選べる中身"
        case .logo: "職人のサイン代わり"
        }
    }

    var detailDescription: String {
        switch self {
        case .eye:
            "こんがりと焼き上がった目元。たい焼きの愛嬌はこの目で決まります。型に刻まれた焼き目がくっきり出るのが良いたい焼きの証です。"
        case .mouth:
            "ちょこんと結んだ小さな口。頭から食べるか、尾から食べるか。永遠の議論はこの口元から始まります。"
        case .tail:
            "生地が薄くカリカリ食感に仕上がる人気部位。あんこが尾まで詰まっているかどうかは、お店のこだわりの見せどころです。"
        case .dorsalFin:
            "型の細かい筋がくっきり並ぶ背びれ。焼き型の彫りの深さがそのまま出る、職人泣かせのディテールです。"
        case .filling:
            "定番のあんこに、カスタード・抹茶・チョコ。下のピッカーで具材を切り替えて、お気に入りの味を見つけてください。"
        case .logo:
            "尾びれの近くに押されたSugiyの焼印。この一匹が正真正銘Sugiy印であることの証です。"
        }
    }
}

/// RealityViewのたい焼きモデルにアンカー付きフォーカスUIを重ねるサンプル。
/// ドラッグで回転し、手前を向いたアンカーだけに「+」ボタンが表示される。
/// タップすると正面を向きながらその部位へズームし、説明パネルを表示する。
public struct TaiyakiFocusView: View {
    /// スライド埋め込みなど、機能を絞って見せたい場面向けの表示モード
    public enum Mode: Sendable {
        /// アンカーバブル+詳細パネル+具材ピッカー(フル機能)
        case full
        /// ドラッグ回転と具材切り替えのみ(タップ・説明UIなし)
        case fillingOnly
    }

    private let mode: Mode

    public init(mode: Mode = .full) {
        self.mode = mode
    }

    /// 回転の中心となるpivot Entity
    @State private var pivotEntity: Entity?
    /// 読み込んだモデル(scene)
    @State private var sceneEntity: Entity?
    /// 現在のモデル回転
    @State private var modelRotation = simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)
    /// フォーカス前の回転(クローズ時に復元する)
    @State private var preFocusRotation = simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)
    /// ドラッグ差分計算用
    @State private var lastDragTranslation: CGSize = .zero
    /// pivot空間でのアンカー位置(ロード時に一度だけ計算)
    @State private var anchorLocalPositions: [TaiyakiPart: SIMD3<Float>] = [:]
    /// フォーカス中の部位(nilなら通常表示)
    @State private var focusedPart: TaiyakiPart?
    /// フォーカスアニメーション中はボタンを隠す
    @State private var isTransitioning = false
    /// 現在の具材
    @State private var selectedFilling: TaiyakiFilling = .redBeans
    /// ロード失敗時のメッセージ
    @State private var loadErrorMessage: String?

    // カメラ設定(射影計算と一致させること)
    private let cameraPosition = SIMD3<Float>(0, 0, 1.2)
    private let cameraFovDegrees: Float = 60
    // フォーカス時の拡大率・移動先・向き
    private let focusScale: Float = 2.3
    private let focusTarget = SIMD3<Float>(-0.12, 0.02, 0.45)
    /// フォーカス時はほぼ正面(わずかに前傾)を向かせる
    private var focusRotation: simd_quatf {
        simd_quatf(angle: -0.12, axis: SIMD3<Float>(1, 0, 0))
    }
    // バブルUIの寸法(重なり判定にも使用)
    private let bubbleButtonSize: CGFloat = 40
    private let bubbleLabelWidth: CGFloat = 150
    private let bubbleHeight: CGFloat = 54

    public var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.black.ignoresSafeArea()

                if let loadErrorMessage {
                    Text(loadErrorMessage)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    realityView

                    if mode == .full, focusedPart == nil && !isTransitioning {
                        anchorBubbles(in: proxy.size)
                    }

                    if mode == .full, let part = focusedPart, !isTransitioning {
                        detailPanel(for: part, in: proxy.size)
                    }

                    VStack {
                        Spacer()
                        if focusedPart == nil {
                            if mode == .full {
                                Text("モデルをドラッグして回転 / ＋をタップで詳細")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.7))
                            }
                            fillingPicker
                                .padding(.horizontal, 24)
                                .padding(.bottom, 24)
                        }
                    }
                }
            }
        }
        .onChange(of: selectedFilling) { _, newValue in
            guard let sceneEntity else { return }
            applyFilling(newValue, to: sceneEntity)
        }
    }

    // MARK: - 具材ピッカー

    /// 標準のsegmented Pickerだと環境フォントの影響でラベルだけ巨大になり、
    /// 逆にタブ側の文字は小さいままなので、フォントを明示できるカスタム版にしている。
    /// (ラベル「具材」は控えめ、タブの具材名は大きめ)
    private var fillingPicker: some View {
        HStack(spacing: 14) {
            Text("具材")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.white.opacity(0.75))
            HStack(spacing: 8) {
                ForEach(TaiyakiFilling.allCases) { filling in
                    Button {
                        selectedFilling = filling
                    } label: {
                        Text(filling.displayName)
                            .font(.system(size: 30, weight: .semibold))
                            .foregroundStyle(selectedFilling == filling ? .black : .white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                Capsule().fill(selectedFilling == filling ? Color.white : Color.white.opacity(0.16))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - RealityView

    private var realityView: some View {
        RealityView { content in
#if !os(visionOS)
            content.camera = .virtual
            let camera = PerspectiveCamera()
            camera.position = cameraPosition
            camera.camera.fieldOfViewInDegrees = cameraFovDegrees
            content.add(camera)
#endif
            let keyLight = DirectionalLight()
            keyLight.light.intensity = 3000
            keyLight.look(at: .zero, from: SIMD3<Float>(1, 1, 1.5), relativeTo: nil)
            content.add(keyLight)

            let fillLight = DirectionalLight()
            fillLight.light.intensity = 1100
            fillLight.look(at: .zero, from: SIMD3<Float>(-1, -0.4, 1), relativeTo: nil)
            content.add(fillLight)

            do {
                let scene = try await Entity(named: "Taiyaki", in: sugiyBundle)
                applyFilling(selectedFilling, to: scene)

                let rawBounds = scene.visualBounds(relativeTo: nil)
                let maxExtent = max(rawBounds.extents.x, max(rawBounds.extents.y, rawBounds.extents.z))
                if maxExtent > 0 {
                    scene.scale = SIMD3<Float>(repeating: 0.6 / maxExtent)
                }
                let scaledBounds = scene.visualBounds(relativeTo: nil)
                scene.position = -scaledBounds.center

                scene.generateCollisionShapes(recursive: true)
                scene.components.set(InputTargetComponent())

                let pivot = Entity()
                pivot.name = "TaiyakiFocusPivot"
                pivot.addChild(scene)
                content.add(pivot)

                var positions: [TaiyakiPart: SIMD3<Float>] = [:]
                for part in TaiyakiPart.allCases {
                    if let anchor = scene.findEntity(named: part.rawValue) {
                        positions[part] = anchor.position(relativeTo: pivot)
                    }
                }
                anchorLocalPositions = positions
                pivotEntity = pivot
                sceneEntity = scene
            } catch {
                loadErrorMessage = "モデルの読み込みに失敗しました\n\(error.localizedDescription)"
            }
        } update: { _ in
            // フォーカス/アニメーション中はmove(to:)に任せる(代入するとアニメーションが打ち消される)
            if focusedPart == nil && !isTransitioning {
                pivotEntity?.transform.rotation = modelRotation
            }
        }
        .gesture(
            DragGesture()
                .targetedToAnyEntity()
                .onChanged { value in
                    guard focusedPart == nil, !isTransitioning else { return }
                    let sensitivity: Float = 0.012
                    let deltaX = Float(value.translation.width - lastDragTranslation.width)
                    let deltaY = Float(value.translation.height - lastDragTranslation.height)
                    lastDragTranslation = value.translation
                    let worldY = simd_quatf(angle: deltaX * sensitivity, axis: SIMD3<Float>(0, 1, 0))
                    let worldX = simd_quatf(angle: deltaY * sensitivity, axis: SIMD3<Float>(1, 0, 0))
                    modelRotation = worldY * worldX * modelRotation
                    pivotEntity?.transform.rotation = modelRotation
                }
                .onEnded { _ in
                    lastDragTranslation = .zero
                }
        )
    }

    // MARK: - アンカーバブル(重なり回避付き)

    private struct Bubble: Identifiable {
        let part: TaiyakiPart
        let buttonCenter: CGPoint
        let labelOnRight: Bool
        let rect: CGRect
        let opacity: Double
        var id: String { part.rawValue }
    }

    /// 手前向きのアンカーを「手前向き度が高い順」に貪欲配置し、
    /// 既に配置したバブルと重なるものは表示しない
    private func layoutBubbles(in size: CGSize) -> [Bubble] {
        var candidates: [(part: TaiyakiPart, point: CGPoint, facing: Float)] = []
        for part in TaiyakiPart.allCases {
            guard let info = projectedAnchor(part, in: size), info.facing > 0.2 else { continue }
            candidates.append((part, info.point, info.facing))
        }
        candidates.sort { $0.facing > $1.facing }

        var placed: [Bubble] = []
        for cand in candidates {
            // ラベルはモデル中心(画面中央)から外向きに伸ばす
            let labelOnRight = cand.point.x >= size.width / 2
            let bubbleWidth = bubbleButtonSize + 8 + bubbleLabelWidth
            let centerShift = (bubbleWidth / 2 - bubbleButtonSize / 2)
            let centerX = cand.point.x + (labelOnRight ? centerShift : -centerShift)
            let rect = CGRect(x: centerX - bubbleWidth / 2,
                              y: cand.point.y - bubbleHeight / 2,
                              width: bubbleWidth,
                              height: bubbleHeight)
            let padded = rect.insetBy(dx: -8, dy: -8)
            guard !placed.contains(where: { $0.rect.intersects(padded) }) else { continue }
            let opacity = Double(min(1, (cand.facing - 0.2) / 0.25))
            placed.append(Bubble(part: cand.part, buttonCenter: cand.point,
                                 labelOnRight: labelOnRight, rect: rect, opacity: opacity))
        }
        return placed
    }

    @ViewBuilder
    private func anchorBubbles(in size: CGSize) -> some View {
        ForEach(layoutBubbles(in: size)) { bubble in
            HStack(spacing: 8) {
                if !bubble.labelOnRight { labelCard(for: bubble.part, alignment: .trailing) }
                Button {
                    focus(on: bubble.part)
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: bubbleButtonSize, height: bubbleButtonSize)
                        .background(.blue.opacity(0.85), in: Circle())
                        .overlay(Circle().strokeBorder(.white.opacity(0.6), lineWidth: 1))
                }
                .buttonStyle(.plain)
                if bubble.labelOnRight { labelCard(for: bubble.part, alignment: .leading) }
            }
            .position(x: bubble.rect.midX, y: bubble.rect.midY)
            .opacity(bubble.opacity)
        }
        .animation(.easeInOut(duration: 0.15), value: layoutBubbles(in: size).map(\.id))
    }

    private func labelCard(for part: TaiyakiPart, alignment: HorizontalAlignment) -> some View {
        VStack(alignment: alignment, spacing: 2) {
            Text(part.title)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
            Text(part.shortDescription)
                .font(.system(size: 10.5))
                .foregroundStyle(.white.opacity(0.85))
        }
        .multilineTextAlignment(alignment == .leading ? .leading : .trailing)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .frame(width: bubbleLabelWidth, alignment: alignment == .leading ? .leading : .trailing)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
        .environment(\.colorScheme, .dark)
    }

    // MARK: - 詳細パネル

    private func detailPanel(for part: TaiyakiPart, in size: CGSize) -> some View {
        HStack {
            Spacer()
            VStack(alignment: .leading, spacing: 14) {
                Button {
                    unfocus()
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(.gray.opacity(0.7), in: Circle())
                        .overlay(Circle().strokeBorder(.white.opacity(0.6), lineWidth: 1))
                }
                .buttonStyle(.plain)

                Text(part.title)
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                Text(part == .filling
                     ? part.detailDescription + "\n(いまの具材: \(selectedFilling.displayName))"
                     : part.detailDescription)
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.9))
                    .lineSpacing(4)
            }
            .padding(16)
            .frame(width: min(size.width * 0.46, 300))
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .environment(\.colorScheme, .dark)
            .padding(.trailing, 16)
        }
        .frame(maxHeight: .infinity, alignment: .center)
        .transition(.opacity.combined(with: .move(edge: .trailing)))
    }

    // MARK: - フォーカス制御

    private func focus(on part: TaiyakiPart) {
        guard let pivot = pivotEntity, let local = anchorLocalPositions[part] else { return }
        isTransitioning = true
        preFocusRotation = modelRotation

        // 正面(わずかに前傾)を向きながら、アンカーがfocusTargetに来るようにズーム
        let rotation = focusRotation
        let translation = focusTarget - rotation.act(local * focusScale)
        let target = Transform(scale: SIMD3<Float>(repeating: focusScale),
                               rotation: rotation,
                               translation: translation)
        pivot.move(to: target, relativeTo: nil, duration: 0.7, timingFunction: .easeInOut)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            pivot.transform = target  // 最終状態を確定させる
            withAnimation(.easeInOut(duration: 0.25)) {
                focusedPart = part
                isTransitioning = false
            }
        }
    }

    private func unfocus() {
        guard let pivot = pivotEntity else { return }
        isTransitioning = true
        withAnimation(.easeInOut(duration: 0.2)) {
            focusedPart = nil
        }
        let base = Transform(scale: .one, rotation: preFocusRotation, translation: .zero)
        pivot.move(to: base, relativeTo: nil, duration: 0.6, timingFunction: .easeInOut)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
            pivot.transform = base  // 倍率・位置を確実に復元する
            modelRotation = preFocusRotation
            isTransitioning = false
        }
    }

    // MARK: - 射影計算

    /// アンカーのスクリーン座標と「手前向き度」(0..1)を返す
    private func projectedAnchor(_ part: TaiyakiPart, in size: CGSize) -> (point: CGPoint, facing: Float)? {
        guard let local = anchorLocalPositions[part] else { return nil }
        let world = modelRotation.act(local)

        let dir = simd_length(local) > 0 ? simd_normalize(world) : SIMD3<Float>(0, 0, 1)
        let facing = dir.z

        let rel = world - cameraPosition
        guard rel.z < -0.01 else { return nil }
        let tanHalf = tan(cameraFovDegrees * .pi / 180 / 2)
        let xProj = rel.x / (-rel.z) / tanHalf
        let yProj = rel.y / (-rel.z) / tanHalf
        let halfH = size.height / 2
        let point = CGPoint(x: size.width / 2 + CGFloat(xProj) * halfH,
                            y: size.height / 2 - CGFloat(yProj) * halfH)
        guard point.x > -60, point.x < size.width + 60,
              point.y > -60, point.y < size.height + 60 else { return nil }
        return (point, facing)
    }

    /// 選択された具材のみ表示
    private func applyFilling(_ filling: TaiyakiFilling, to root: Entity) {
        for candidate in TaiyakiFilling.allCases {
            root.findEntity(named: candidate.rawValue)?.isEnabled = (candidate == filling)
        }
    }
}

#Preview {
    TaiyakiFocusView()
}
