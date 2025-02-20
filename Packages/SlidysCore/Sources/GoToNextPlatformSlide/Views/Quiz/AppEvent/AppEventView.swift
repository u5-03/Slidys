//
//  AppEventView.swift
//  SlidysCore
//
//  Created by yugo.sugiyama on 2025/02/19.
//

import SwiftUI

struct AppEventView: View {
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    ForEach(0..<10) {
                        Color.blue
                            .brightness(Double($0) * 0.1)
                    }
                }
                .containerRelativeFrame(.vertical) { length, _ in
                    return length * 0.7
                }
                PlaygroundView()
            }
            Text("ポイント 10,000pt")
                .font(.system(size: 20, weight: .black))
                .foregroundStyle(.black)
                .stroked(color: Color.white, width: 2)
                .offset(x: 240, y: 40)
            Image(systemName: "figure.strengthtraining.functional.circle.fill")
                .resizable()
                .foregroundStyle(.red)
                .frame(width: 60, height: 60)
                .rotationEffect(.degrees(-30))
                .offset(x: -250, y: 20)
            Image(systemName: "figure.jumprope.circle.fill")
                .resizable()
                .foregroundStyle(.blue)
                .frame(width: 60, height: 60)
                .rotationEffect(.degrees(30))
                .offset(x: 0, y: 0)
            Image(systemName: "figure.outdoor.cycle.circle.fill")
                .resizable()
                .foregroundStyle(.yellow)
                .frame(width: 60, height: 60)
                .rotationEffect(.degrees(-20))
                .offset(x: 200, y: -10)
            GaugeView()
                .backgroundStyle(.white)
                .padding(.horizontal, 40)
                .offset(y: 100)
            Text("Mission Complete")
                .foregroundStyle(.white)
                .font(.system(size: 60, weight: .bold))
                .stroked(color: Color.black, width: 1)
                .offset(y: -80)
        }
    }
}

#Preview {
    AppEventView()
}
