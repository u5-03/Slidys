//
//  HandSkeletonDiagramSlide.swift
//  iOSDC2025Slide
//
//  Created by Claude on 2025/01/20.
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct HandSkeletonDiagramSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0

    var body: some View {
        HeaderSlide("【参考】HandSkeleton関節の詳細(visionOS2からhandのprefixなし)") {
            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                // HandSkeleton図の画像
                Image(.handSkeltonStructure)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(10)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                scale = lastScale * value
                            }
                            .onEnded { _ in
                                lastScale = scale
                            }
                    )
                    .onTapGesture(count: 2) {
                        withAnimation(.easeInOut) {
                            if scale > 1.0 {
                                scale = 1.0
                                lastScale = 1.0
                            } else {
                                scale = 2.0
                                lastScale = 2.0
                            }
                        }
                    }
            }

            // 参照元URL
            Link(
                destination: URL(
                    string: "https://developer.apple.com/videos/play/wwdc2023/10082/?time=970")!
            ) {
                Text("参照: Meet ARKit for spatial computing")
                    .font(.system(size: 35, weight: .medium))
                    .underline()
                    .foregroundColor(.blue)
            }
        }
    }
}

#Preview {
    SlidePreview {
        HandSkeletonDiagramSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
