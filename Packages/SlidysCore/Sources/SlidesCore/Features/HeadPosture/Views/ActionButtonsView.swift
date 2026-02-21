//
//  ActionButtonsView.swift
//  HeadPosturePackage
//
//  Created by Claude on 2025/02/07.
//

import SwiftUI
import simd

struct ActionButtonsView: View {
    @Binding var motionManager: HeadMotionManager
    @Binding var threshold: PostureThreshold
    @Binding var showAirPodsRequiredAlert: Bool
    @Binding var isFrontViewMode: Bool
    @Binding var cameraRotation: simd_quatf

    let isMonitoring: Bool
    let isPreviewMode: Bool
    let isMotionPermissionGranted: Bool

    /// ボタンが有効かどうか（権限がある場合のみ有効）
    private var areButtonsEnabled: Bool {
        isMotionPermissionGranted
    }

    var body: some View {
        HStack(spacing: 12) {
            Button(
                action: {
                    if !isPreviewMode {
                        isFrontViewMode = false
                        motionManager.resetReference()
                    }
                },
                label: {
                    HStack(spacing: 6) {
                        Image(systemName: "scope")
                        Text("基準をセット")
                    }
                    .frame(maxWidth: .infinity, minHeight: 44)
                }
            )
            .buttonStyle(.bordered)
            .disabled(!areButtonsEnabled)
            .contextMenu {
                Button {
                    isFrontViewMode = true
                    cameraRotation = simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)
                } label: {
                    Label {
                        Text("正面から見る")
                    } icon: {
                        Image(systemName: "face.smiling")
                    }
                }
            }

            Button(
                action: {
                    if !isPreviewMode {
                        if motionManager.isMonitoring {
                            motionManager.stopMonitoring()
                        } else {
                            guard motionManager.isAvailable else {
                                showAirPodsRequiredAlert = true
                                return
                            }
                            isFrontViewMode = false
                            motionManager.updateThreshold(threshold)
                            motionManager.resetReference()
                            motionManager.startMonitoring()
                        }
                    }
                },
                label: {
                    HStack(spacing: 6) {
                        Image(systemName: isMonitoring ? "stop.fill" : "play.fill")
                        Text(isMonitoring ? "停止" : "開始")
                    }
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, minHeight: 44)
                }
            )
            .buttonStyle(.borderedProminent)
            .tint(isMonitoring ? .red : .green)
            .disabled(!areButtonsEnabled)
        }
    }
}
