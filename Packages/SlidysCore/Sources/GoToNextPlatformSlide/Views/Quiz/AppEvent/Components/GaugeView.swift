//
//  GaugeView.swift
//  SlidysCore
//
//  Created by yugo.sugiyama on 2025/02/19.
//

import SwiftUI

struct GaugeView: View {
    @State private var value: CGFloat = 0
    @State private var percentage: Double = 0
    private let duration: TimeInterval = 10
    let fps: Double = 60.0

    var body: some View {
        ZStack(alignment: .center) {
            Color.white.grayscale(0.5)
            ZStack(alignment: .center) {
                gaugeView(color: .green)
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.black)
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .scaleEffect(x: value, anchor: .leading)
                }
                .mask {
                    Text("\(Int(percentage))%")
                        .font(.system(size: 24, weight: .bold))
                }
            }
            .padding(8)
        }
        .frame(height: 74)
        .mask(Capsule()
            .frame(height: 74)
        )
        .task {
            startCounting()
        }
        .preferredColorScheme(.dark)
    }

    private func startCounting() {
        let totalFrames = duration * fps
        let interval = duration / totalFrames
        let increment = 100.0 / totalFrames

        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            if percentage < 100 {
                percentage = min(100, percentage + Double(increment))
                // macOSでwithAnimationでのアニメーションが動かなかったので、手動で値を増やす
                value = percentage / 100
            } else {
                timer.invalidate()
                percentage = 0
                startCounting()
                value = 0
            }
        }
    }
}

private extension GaugeView {
    func gaugeView(color: Color) -> some View {
        Gauge(value: value) {
            EmptyView()
        }
        .gaugeStyle(.linearCapacity)
        .tint(color)
        .background(.white)
        .scaleEffect(.init(width: 1, height: 4), anchor: .center)
        .mask(Capsule()
            .frame(height: 60)
        )
    }
}

#Preview {
    @Previewable @State var value: CGFloat = 0.5
    GaugeView()
}
