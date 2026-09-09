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

    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    /// スピーカーノート(発表者用の原稿。ノートWindowに表示される)
    public let script: String

    public init(videoType: VideoType, script: String = "") {
        self.videoType = videoType
        self.script = script
    }

    public var body: some View {
        VideoView(videoType: videoType)
    }
}

#Preview {
    VideoSlide(videoType: .visionProDemoInput)
        .frame(width: 800, height: 450)
}
