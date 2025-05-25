//
//  Created by yugo.a.sugiyama on 2025/05/24
//  Copyright ©Sugiy All rights reserved.
//

import SwiftUI
import SlideKit
import SlidesCore
import SymbolKit

@Slide
struct ComparePlatformAnimationSlide: View {
    var body: some View {
        HeaderSlide("Compare SwiftUI and Flutter animation") {
            VStack(spacing: 20) {
                HStack(alignment: .center) {
                    StrokeAnimationShapeView(
                        shape: SugiyShape(),
                        lineWidth: 6,
                        lineColor: .white,
                        duration: .seconds(30),
                        shapeAspectRatio: SugiyShape.aspectRatio,
                        viewModel: .init(animationType: .progressiveDraw)
                    )
                    FlutterView(type: .iconWithoutLoop)
                        .padding(.bottom, 48)
                }
                HStack {
                    Spacer()
                    Text("SwiftUI")
                        .font(.mediumFont)
                    Spacer()
                    Text("Flutter")
                        .font(.mediumFont)
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    SlidePreview {
        ImplementationContentMoveSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
