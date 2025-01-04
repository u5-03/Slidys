//
//  MusicNoteMaskView.swift
//  iOSDC2024Slide
//
//  Created by Yugo Sugiyama on 2024/08/12.
//

import SwiftUI

struct MusicNoteMaskView: View {
    let colorfulGradient = Gradient(
        colors: [.red, .orange, .yellow, .green, .blue, .purple, .pink]
            .map({ (color: Color) in color.opacity(0.8) })
    )
    @State private var gradientAngle: Angle = .degrees(0)

    var body: some View {
        AngularGradient(
            gradient: colorfulGradient,
            center: .leading,
            angle: gradientAngle
        )
        .mask({
            Image(.trebleClef)
                .resizable()
                .scaledToFit()
        })
        .onAppear {
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                gradientAngle = .degrees(360)
            }
        }
    }
}

#Preview {
    HStack(spacing: 0) {
        MusicNoteMaskView()
    }
}
