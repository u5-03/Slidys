//
//  HandSkeletonDiagramSlide.swift
//  iOSDC2025Slide
//
//  Created by Claude on 2025/01/20.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct HandSkeletonDiagramSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }
    
    var body: some View {
        HeaderSlide("HandSkeleton関節の詳細(visionOS2からhandのprefixなし)") {
            // HandSkeleton図の画像
            Image(.handSkeltonStructure)
                .resizable()
                .scaledToFit()
                .cornerRadius(10)

            // 参照元URL
            Link(destination: URL(string: "https://developer.apple.com/videos/play/wwdc2023/10082/?time=970")!) {
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
