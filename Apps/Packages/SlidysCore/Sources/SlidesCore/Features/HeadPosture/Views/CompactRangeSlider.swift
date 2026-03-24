//
//  CompactRangeSlider.swift
//  HeadPosturePackage
//
//  Created by Yugo Sugiyama on 2025/12/14.
//

import SwiftUI

struct CompactRangeSlider: View {
    let currentValue: Double
    @Binding var minValue: Double
    @Binding var maxValue: Double
    let range: ClosedRange<Double>
    let color: Color
    var isDisabled = false

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width

            ZStack(alignment: .leading) {
                // 背景
                Capsule()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 4)

                // 範囲ハイライト
                let minX = positionForValue(minValue, width: width)
                let maxX = positionForValue(maxValue, width: width)

                Capsule()
                    .fill(color.opacity(0.3))
                    .frame(width: max(0, maxX - minX), height: 4)
                    .offset(x: minX)

                // 現在値
                let currentX = positionForValue(currentValue, width: width)
                Circle()
                    .fill(isWithinRange ? color : .red)
                    .frame(width: 8, height: 8)
                    .offset(x: currentX - 4)

                // 最小ハンドル（44x44のタップ領域を確保）
                Circle()
                    .fill(Color.white)
                    .frame(width: 20, height: 20)
                    .shadow(radius: 1)
                    .overlay(Circle().stroke(color, lineWidth: 2))
                    .frame(width: 44, height: 44)
                    .contentShape(Circle().scale(2.2))
                    .offset(x: minX - 22)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                guard !isDisabled else { return }
                                let newValue = valueForPosition(value.location.x, width: width)
                                minValue = min(newValue, maxValue - 0.1)
                            }
                    )

                // 最大ハンドル（44x44のタップ領域を確保）
                Circle()
                    .fill(Color.white)
                    .frame(width: 20, height: 20)
                    .shadow(radius: 1)
                    .overlay(Circle().stroke(color, lineWidth: 2))
                    .frame(width: 44, height: 44)
                    .contentShape(Circle().scale(2.2))
                    .offset(x: maxX - 22)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                guard !isDisabled else { return }
                                let newValue = valueForPosition(value.location.x, width: width)
                                maxValue = max(newValue, minValue + 0.1)
                            }
                    )
            }
        }
        .frame(height: 44)
    }

    private var isWithinRange: Bool {
        currentValue >= minValue && currentValue <= maxValue
    }

    private func positionForValue(_ value: Double, width: CGFloat) -> CGFloat {
        let clampedValue = max(min(value, range.upperBound), range.lowerBound)
        let ratio = (clampedValue - range.lowerBound) / (range.upperBound - range.lowerBound)
        return CGFloat(ratio) * width
    }

    private func valueForPosition(_ position: CGFloat, width: CGFloat) -> Double {
        let ratio = Double(max(0, min(position, width)) / width)
        return range.lowerBound + ratio * (range.upperBound - range.lowerBound)
    }
}

struct CompactThresholdConfig {
    let titleKey: LocalizedStringKey
    let icon: String
    let color: Color
    let currentValue: Double
    let minValue: Binding<Double>
    let maxValue: Binding<Double>
}
