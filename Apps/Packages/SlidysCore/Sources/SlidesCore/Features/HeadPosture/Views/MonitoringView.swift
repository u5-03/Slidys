//
//  MonitoringView.swift
//  HeadPosturePackage
//
//  Created by Yugo Sugiyama on 2025/12/14.
//

#if !os(visionOS)
import SwiftUI
import RealityKit
import simd

public struct MonitoringView: View {
    @State private var motionManager = HeadMotionManager()
    @State private var headEntity: Entity?
    @State private var threshold = PostureThreshold()
    @State private var helmetEntity: Entity?
    @State private var needsHelmetUpdate = false

    // カメラ回転用の状態（クォータニオンで管理）
    @State private var cameraRotation = simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)
    @State private var lastDragTranslation = CGSize.zero
    @State private var lastRotationAngle = Angle.zero
    @State private var cameraEntity: Entity?

    // 正面表示モード（ジャイロを無視して正面から見る）
    @State private var isFrontViewMode = false

    // ドラッグヒントアニメーション用
    @State private var showDragHint = true
    @State private var dragHintOffset: CGFloat = -40

    // AirPods未装着アラート用
    @State private var showAirPodsRequiredAlert = false

    /// 外部から注入される状態（プレビュー用）
    private let previewState: MonitoringViewState?

    /// 通常のイニシャライザ
    public init() {
        self.previewState = nil
    }

    /// プレビュー用イニシャライザ（状態を外部から注入）
    init(previewState: MonitoringViewState, cameraRotationDegrees: Double = 45) {
        self.previewState = previewState
        let radians = Float(cameraRotationDegrees * .pi / 180)
        self._cameraRotation = State(initialValue: simd_quatf(angle: radians, axis: SIMD3<Float>(0, 1, 0)))
    }

    // MARK: - Computed Properties

    private var isPreviewMode: Bool {
        previewState != nil
    }

    private var isMonitoring: Bool {
        previewState?.isMonitoring ?? motionManager.isMonitoring
    }

    private var isAvailable: Bool {
        previewState?.isAvailable ?? motionManager.isAvailable
    }

    private var currentViolation: ThresholdViolation? {
        previewState?.currentViolation ?? motionManager.currentViolation
    }

    private var rollValue: Double {
        previewState?.roll ?? motionManager.roll
    }

    private var yawValue: Double {
        previewState?.yaw ?? motionManager.yaw
    }

    private var pitchValue: Double {
        previewState?.pitch ?? motionManager.pitch
    }

    private var isMotionPermissionGranted: Bool {
        isPreviewMode ? true : motionManager.isMotionPermissionGranted
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // プレビューセクション（RealityView）
                MonitoringChartView(
                    motionManager: $motionManager,
                    threshold: $threshold,
                    headEntity: $headEntity,
                    helmetEntity: $helmetEntity,
                    needsHelmetUpdate: $needsHelmetUpdate,
                    cameraRotation: $cameraRotation,
                    lastDragTranslation: $lastDragTranslation,
                    lastRotationAngle: $lastRotationAngle,
                    cameraEntity: $cameraEntity,
                    showDragHint: $showDragHint,
                    dragHintOffset: $dragHintOffset,
                    isFrontViewMode: $isFrontViewMode,
                    isMonitoring: isMonitoring,
                    isAvailable: isAvailable,
                    currentViolation: currentViolation,
                    isPreviewMode: isPreviewMode,
                    isMotionPermissionGranted: isMotionPermissionGranted
                )

                // コントロール（ボタン + 閾値スライダー）
                controlsView
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 16)
        }
        .navigationTitle(Text("モニタリング"))
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .alert(Text("AirPodsが必要です"), isPresented: $showAirPodsRequiredAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("モーションセンサー対応のAirPodsを接続してください")
        }
        .onAppear {
            if !isPreviewMode {
                motionManager.startTracking()
                Task {
                    await motionManager.requestMotionPermission()
                }
            }
        }
        .onDisappear {
            if !isPreviewMode {
                motionManager.stopTracking()
            }
        }
    }

    // MARK: - Subviews

    private var controlsView: some View {
        let controls = MonitoringControlsView(
            motionManager: $motionManager,
            threshold: $threshold,
            needsHelmetUpdate: $needsHelmetUpdate,
            showAirPodsRequiredAlert: $showAirPodsRequiredAlert,
            isFrontViewMode: $isFrontViewMode,
            cameraRotation: $cameraRotation,
            isMonitoring: isMonitoring,
            rollValue: rollValue,
            yawValue: yawValue,
            pitchValue: pitchValue,
            isPreviewMode: isPreviewMode,
            isMotionPermissionGranted: isMotionPermissionGranted
        )

        return VStack(spacing: 12) {
            controls.actionButtonsView
            controls.thresholdControlsView
        }
    }
}

#Preview("Idle") {
    NavigationStack {
        MonitoringView(previewState: .idle)
    }
}

#Preview("Monitoring") {
    NavigationStack {
        MonitoringView(previewState: .monitoring)
    }
}

#Preview("Disconnected") {
    NavigationStack {
        MonitoringView(previewState: .disconnected)
    }
}

#Preview("Live") {
    NavigationStack {
        MonitoringView()
    }
}
#endif
