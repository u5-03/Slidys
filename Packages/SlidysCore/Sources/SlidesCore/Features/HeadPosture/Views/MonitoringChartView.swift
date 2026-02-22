//
//  MonitoringChartView.swift
//  HeadPosturePackage
//
//  Created by Yugo Sugiyama on 2025/12/14.
//

#if !os(visionOS)
import SwiftUI
import RealityKit
import simd

struct MonitoringChartView: View {
    @Binding var motionManager: HeadMotionManager
    @Binding var threshold: PostureThreshold
    @Binding var headEntity: Entity?
    @Binding var helmetEntity: Entity?
    @Binding var needsHelmetUpdate: Bool
    @Binding var cameraRotation: simd_quatf
    @Binding var lastDragTranslation: CGSize
    @Binding var lastRotationAngle: Angle
    @Binding var cameraEntity: Entity?
    @Binding var showDragHint: Bool
    @Binding var dragHintOffset: CGFloat
    @Binding var isFrontViewMode: Bool

    let isMonitoring: Bool
    let isAvailable: Bool
    let currentViolation: ThresholdViolation?
    let isPreviewMode: Bool
    let isMotionPermissionGranted: Bool

    @ScaledMetric(relativeTo: .caption) private var statusIndicatorSize: CGFloat = 8
    @ScaledMetric(relativeTo: .body) private var previewHeight: CGFloat = 240

    /// 設定アプリを開く
    private func openSettings() {
#if canImport(UIKit)
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
#endif
    }

    var body: some View {
        ZStack {
            RealityView { content in
                content.camera = .virtual

                let cameraRoot = Entity()
                cameraRoot.position = SIMD3<Float>(0, 0, 0)
                cameraEntity = cameraRoot
                content.add(cameraRoot)

                let headScale: Float = 1.5
                let (head, _, _) = AirPodsModelEntity.createFrontViewHead(scale: headScale)
                head.position = SIMD3<Float>(0, 0, 0)
                headEntity = head
                cameraRoot.addChild(head)

                let helmet = RangeHelmetEntity.createHelmet(threshold: threshold, radius: 0.75, scale: headScale)
                helmetEntity = helmet
                cameraRoot.addChild(helmet)

                let light = DirectionalLight()
                light.light.intensity = 2000
                light.look(at: [0, 0, 0], from: [0.5, 1, 1], relativeTo: nil)
                content.add(light)

                let ambientLight = DirectionalLight()
                ambientLight.light.intensity = 800
                ambientLight.look(at: [0, 0, 0], from: [-0.5, -1, -1], relativeTo: nil)
                content.add(ambientLight)
            } update: { _ in
                let relativeQuaternion = simd_quatf(
                    ix: Float(motionManager.relativeQuaternionX),
                    iy: Float(motionManager.relativeQuaternionZ),
                    iz: -Float(motionManager.relativeQuaternionY),
                    r: Float(motionManager.relativeQuaternionW)
                )

                if let head = headEntity {
                    if isFrontViewMode {
                        head.transform.rotation = simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)
                    } else {
                        head.transform.rotation = relativeQuaternion
                    }
                }

                if let camera = cameraEntity {
                    camera.transform.rotation = cameraRotation
                }

                if needsHelmetUpdate, let oldHelmet = helmetEntity {
                    if let camera = cameraEntity {
                        oldHelmet.removeFromParent()
                        let headScale: Float = 1.5
                        let newHelmet = RangeHelmetEntity.createHelmet(threshold: threshold, radius: 0.75, scale: headScale)
                        helmetEntity = newHelmet
                        camera.addChild(newHelmet)
                    }
                    needsHelmetUpdate = false
                }
            }
            .frame(height: previewHeight)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        isFrontViewMode = false
                        let sensitivity: Float = 0.012
                        let deltaX = Float(value.translation.width) - Float(lastDragTranslation.width)
                        let deltaY = Float(value.translation.height) - Float(lastDragTranslation.height)
                        lastDragTranslation = value.translation

                        let worldYRotation = simd_quatf(angle: deltaX * sensitivity, axis: SIMD3<Float>(0, 1, 0))
                        let worldXRotation = simd_quatf(angle: deltaY * sensitivity, axis: SIMD3<Float>(1, 0, 0))

                        cameraRotation = worldYRotation * worldXRotation * cameraRotation
                    }
                    .onEnded { _ in
                        lastDragTranslation = .zero
                    }
            )
            .simultaneousGesture(
                RotationGesture()
                    .onChanged { value in
                        let deltaAngle = Float(value.radians - lastRotationAngle.radians)
                        lastRotationAngle = value

                        let worldZRotation = simd_quatf(angle: -deltaAngle, axis: SIMD3<Float>(0, 0, 1))
                        cameraRotation = worldZRotation * cameraRotation
                    }
                    .onEnded { _ in
                        lastRotationAngle = .zero
                    }
            )

            // オーバーレイ
            VStack {
                HStack {
                    // 状態表示
                    HStack(spacing: 4) {
                        Circle()
                            .fill(isMonitoring ? Color.green : Color.gray)
                            .frame(width: statusIndicatorSize, height: statusIndicatorSize)
                        Text(isMonitoring ? "監視中" : "停止中")
                            .font(.caption2)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())

                    Spacer()

                    // 視点リセット
                    if cameraRotation != simd_quatf(ix: 0, iy: 0, iz: 0, r: 1) {
                        Button(
                            action: {
                                cameraRotation = simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)
                            },
                            label: {
                                Image(systemName: "viewfinder")
                                    .font(.title2)
                                    .foregroundStyle(.cyan.opacity(0.85))
                                    .frame(minWidth: 44, minHeight: 44)
                            }
                        )
                    }
                }
                Spacer()
            }
            .padding(6)

            if currentViolation != nil {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.red, lineWidth: 3)
            }

            // 権限なし → 権限許可メッセージ + 設定ボタン
            // AirPods未接続 → 「AirPodsを接続」メッセージ
            if !isMotionPermissionGranted {
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.title)
                        .foregroundStyle(.orange)
                    Text("モーションセンサーの権限が必要です\n設定アプリで許可してください")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button(action: openSettings) {
                        Text("設定を開く")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.ultraThinMaterial)
            } else if !isAvailable {
                VStack(spacing: 4) {
                    Image(systemName: "airpodspro")
                        .font(.title)
                        .foregroundStyle(.secondary)
                    Text("AirPodsを接続してください")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.ultraThinMaterial)
            }

            // ドラッグヒントアニメーション
            if showDragHint && !isPreviewMode {
                Image(systemName: "hand.point.up.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                    .offset(x: dragHintOffset)
                    .onAppear {
                        withAnimation(
                            .easeInOut(duration: 0.8)
                            .repeatCount(2, autoreverses: true)
                        ) {
                            dragHintOffset = 40
                        }
                        Task { @MainActor in
                            try? await Task.sleep(for: .seconds(1.6))
                            withAnimation(.easeOut(duration: 0.3)) {
                                showDragHint = false
                            }
                        }
                    }
            }
        }
        .frame(height: previewHeight)
        .background(Color.black.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
#endif
