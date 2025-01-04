//
//  OsTitleSlide.swift
//  iOSDC2024Slide
//
//  Created by Yugo Sugiyama on 2024/08/05.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct OsTitleSlide: View {
let shouldAnimated: Bool
private let osNameHeight: CGFloat = 400
@State private var yOffset: CGFloat = 0

var body: some View {
    VStack(alignment: .center, spacing: 40) {
        Text("I developed App of")
            .foregroundStyle(.white)
            .font(.system(size: 120, weight: .heavy))
            .offset(y: osNameHeight)
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 40) {
                LinearGradient(
                    colors: [
                        Color(hex: "73BBC5"),
                        Color(hex: "4072D8"),
                        Color(hex: "436BDD"),
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: 400)
                .mask {
                    Text("iPad")
                        .font(.system(size: 150, weight: .heavy))
                }
                Image(systemName: "ipad.gen1.landscape")
                    .resizable()
                    .foregroundStyle(.gray)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: osNameHeight)
            }
            .frame(height: osNameHeight)
            Text("And...")
                .font(.system(size: 150, weight: .heavy))
                .foregroundStyle(.white)
                .frame(height: osNameHeight)
            HStack(alignment: .center, spacing: 40) {
                LinearGradient(
                    colors: [
                        Color(hex: "393EE2"),
                        Color(hex: "E86780"),
                        Color(hex: "C8BBE2"),
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: 780, height: osNameHeight)
                .mask {
                    Text("Vision Pro")
                        .font(.system(size: 150, weight: .heavy))
                        .frame(height: osNameHeight)
                        .shadow(radius: 10)
                }
                Image(systemName: "visionpro")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.gray)
                    .frame(height: osNameHeight * 0.6)
            }
        }
        .offset(y: osNameHeight)
        .offset(y: yOffset)
        .mask { Rectangle().frame(height: osNameHeight + 10) }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.black)
    .task {
        if !shouldAnimated { return }
        try? await Task.sleep(for: .milliseconds(800))
        withAnimation {
            yOffset = -osNameHeight
        } completion: {
            Task {
                try? await Task.sleep(for: .milliseconds(600))
                withAnimation(.linear(duration: 0.6)) {
                    yOffset += -osNameHeight
                }
            }
        }

    }
}
}

#Preview {
    SlidePreview {
        OsTitleSlide(shouldAnimated: true)
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
