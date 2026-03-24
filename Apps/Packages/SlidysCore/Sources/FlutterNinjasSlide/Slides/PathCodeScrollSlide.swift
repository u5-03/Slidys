//
//  Created by yugo.sugiyama on 2025/05/17
//  Copyright ©Sugiy All rights reserved.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct PathCodeScrollSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        VStack {
            Text("Original Path and generated Flutter Path")
                .font(.mediumFont)
                .lineLimit(1)
                .minimumScaleFactor(0.1)
                .foregroundStyle(.themeColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 100)
            HStack {
                Image(.pathIcon)
                    .resizable()
                    .renderingMode(.template)
                    .tint(.white)
                    .foregroundStyle(.white)
                    .scaledToFit()
                ScrollView {
                    Text(CodeConstants.iconPathStringCode)
                        .font(.tinyFont)
                        .foregroundStyle(.white)
                        .frame(maxHeight: .infinity)
                        .lineLimit(nil)
                        .padding()
                }
            }
        }
        .padding()
        .background(.slideBackgroundColor)
    }
}

#Preview {
    SlidePreview {
        PathCodeScrollSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
