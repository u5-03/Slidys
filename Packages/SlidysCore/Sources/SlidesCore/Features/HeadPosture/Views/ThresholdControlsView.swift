//
//  ThresholdControlsView.swift
//  HeadPosturePackage
//
//  Created by Claude on 2025/02/07.
//

import SwiftUI

struct ThresholdControlsView: View {
    @Binding var threshold: PostureThreshold
    @Binding var needsHelmetUpdate: Bool

    let rollValue: Double
    let yawValue: Double
    let pitchValue: Double
    let isPreviewMode: Bool

    var body: some View {
        VStack(spacing: 8) {
            // 警告時間（コンパクト）
            HStack {
                Image(systemName: "timer")
                    .font(.caption)
                    .foregroundStyle(.orange)
                Text("警告遅延")
                    .font(.caption)
                Text("\(String(format: "%.0f", threshold.warningDelay))\(Text("秒"))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Slider(value: $threshold.warningDelay, in: 1...10, step: 1)
                    .tint(.orange)
                    .frame(width: 100)
                    .disabled(isPreviewMode)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
#if canImport(UIKit)
            .background(Color(UIColor.secondarySystemGroupedBackground))
#else
            .background(Color(nsColor: .controlBackgroundColor))
#endif
            .clipShape(RoundedRectangle(cornerRadius: 8))

            // 閾値スライダー
            VStack(spacing: 6) {
                compactThresholdSlider(config: CompactThresholdConfig(
                    titleKey: "前後",
                    icon: "arrow.up.arrow.down",
                    color: .blue,
                    currentValue: rollValue,
                    minValue: Binding(
                        get: { threshold.rollMin },
                        set: { threshold.rollMin = $0; needsHelmetUpdate = true }
                    ),
                    maxValue: Binding(
                        get: { threshold.rollMax },
                        set: { threshold.rollMax = $0; needsHelmetUpdate = true }
                    )
                ))

                compactThresholdSlider(config: CompactThresholdConfig(
                    titleKey: "左右向き",
                    icon: "arrow.left.arrow.right",
                    color: .green,
                    currentValue: yawValue,
                    minValue: Binding(
                        get: { threshold.yawMin },
                        set: { threshold.yawMin = $0; needsHelmetUpdate = true }
                    ),
                    maxValue: Binding(
                        get: { threshold.yawMax },
                        set: { threshold.yawMax = $0; needsHelmetUpdate = true }
                    )
                ))

                compactThresholdSlider(config: CompactThresholdConfig(
                    titleKey: "左右傾き",
                    icon: "arrow.left.and.right.righttriangle.left.righttriangle.right",
                    color: .red,
                    currentValue: pitchValue,
                    minValue: Binding(
                        get: { threshold.pitchMin },
                        set: { threshold.pitchMin = $0; needsHelmetUpdate = true }
                    ),
                    maxValue: Binding(
                        get: { threshold.pitchMax },
                        set: { threshold.pitchMax = $0; needsHelmetUpdate = true }
                    )
                ))
            }
            .padding(10)
#if canImport(UIKit)
            .background(Color(UIColor.secondarySystemGroupedBackground))
#else
            .background(Color(nsColor: .controlBackgroundColor))
#endif
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    // MARK: - Private Methods

    private func compactThresholdSlider(config: CompactThresholdConfig) -> some View {
        VStack(spacing: 2) {
            HStack {
                Image(systemName: config.icon)
                    .font(.caption2)
                    .foregroundStyle(config.color)
                Text(config.titleKey)
                    .font(.caption)
                Spacer()
                Text("\(Int(config.currentValue * 180 / .pi))°")
                    .font(.caption)
                    .fontWeight(.medium)
                    .monospacedDigit()
                    .foregroundColor(
                        isWithinThreshold(config.currentValue, min: config.minValue.wrappedValue, max: config.maxValue.wrappedValue)
                        ? config.color
                        : .red
                    )
            }

            CompactRangeSlider(
                currentValue: config.currentValue,
                minValue: config.minValue,
                maxValue: config.maxValue,
                range: -.pi/2 ... .pi/2,
                color: config.color,
                isDisabled: isPreviewMode
            )
        }
    }

    private func isWithinThreshold(_ value: Double, min: Double, max: Double) -> Bool {
        value >= min && value <= max
    }
}
