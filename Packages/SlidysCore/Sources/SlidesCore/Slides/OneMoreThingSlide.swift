//
//  OneMoreThingSlide.swift
//  iOSDC2024Slide
//
//  Created by Yugo Sugiyama on 2024/08/05.
//

import SwiftUI
import SlideKit

@Slide
public struct OneMoreThingSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    /// スピーカーノート(発表者用の原稿。ノートWindowに表示される)
    public let script: String

    public init(script: String = "") {
        self.script = script
    }

    public var body: some View {
        VStack {
            Spacer()
            LinearGradient(
                colors: [
                    .white,
                    .gray
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 180)
            .mask {
                Text("One more thing...")
                    .font(.system(size: 160, weight: .bold))
            }
            Spacer()
        }
        .background(Color.black)
    }
}

#Preview {
    SlidePreview {
        OneMoreThingSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
