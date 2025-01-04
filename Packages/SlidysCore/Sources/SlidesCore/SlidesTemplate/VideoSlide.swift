//
//  VideoSlide.swift
//  iOSDC2024Slide
//
//  Created by Yugo Sugiyama on 2024/07/27.
//

import SwiftUI
import SlideKit

@Slide
public struct VideoSlide: View {
    let videoType: VideoType

    public init(videoType: VideoType) {
        self.videoType = videoType
    }

    public var body: some View {
        VideoView(videoType: videoType)
    }
}

#Preview {
    VideoSlide(videoType: .visionProDemoInput)
        .frame(width: 800, height: 450)
}
