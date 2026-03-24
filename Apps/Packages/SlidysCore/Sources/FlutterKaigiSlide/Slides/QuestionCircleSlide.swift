//
//  QuestionCircleSlide.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/11/06.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct QuestionCircleSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        VStack(spacing: 0) {
            Text("このUIを作ってくださいと言われたら、\nどうしますか？")
                .font(.largeFont)
            Spacer()
                .frame(height: 12)
            FlutterView(type: .circle)
                .aspectRatio(contentMode: .fit)
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.slideBackgroundColor)
        .foregroundColor(.defaultForegroundColor)
    }
}

#Preview {
    SlidePreview {
        QuestionCircleSlide()
    }
}
