//
//  MonitoringControlsView.swift
//  HeadPosturePackage
//
//  Created by Yugo Sugiyama on 2025/12/14.
//

import SwiftUI
import simd

struct MonitoringControlsView: View {
    @Binding var motionManager: HeadMotionManager
    @Binding var threshold: PostureThreshold
    @Binding var needsHelmetUpdate: Bool
    @Binding var showAirPodsRequiredAlert: Bool
    @Binding var isFrontViewMode: Bool
    @Binding var cameraRotation: simd_quatf

    let isMonitoring: Bool
    let rollValue: Double
    let yawValue: Double
    let pitchValue: Double
    let isPreviewMode: Bool
    let isMotionPermissionGranted: Bool

    var body: some View {
        VStack(spacing: 12) {
            actionButtonsView

            thresholdControlsView
        }
    }

    // MARK: - Subviews

    var actionButtonsView: some View {
        ActionButtonsView(
            motionManager: $motionManager,
            threshold: $threshold,
            showAirPodsRequiredAlert: $showAirPodsRequiredAlert,
            isFrontViewMode: $isFrontViewMode,
            cameraRotation: $cameraRotation,
            isMonitoring: isMonitoring,
            isPreviewMode: isPreviewMode,
            isMotionPermissionGranted: isMotionPermissionGranted
        )
    }

    var thresholdControlsView: some View {
        ThresholdControlsView(
            threshold: $threshold,
            needsHelmetUpdate: $needsHelmetUpdate,
            rollValue: rollValue,
            yawValue: yawValue,
            pitchValue: pitchValue,
            isPreviewMode: isPreviewMode
        )
    }
}
