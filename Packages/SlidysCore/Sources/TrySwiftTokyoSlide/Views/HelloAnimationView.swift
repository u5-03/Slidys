//
//  Created by yugo.sugiyama on 2025/03/12
//  Copyright ©Sugiy All rights reserved.
//

import SwiftUI
import SymbolKit

struct HelloAnimationView: View {
    let duration: Duration

    init(duration: Duration = .seconds(3)) {
        self.duration = duration
    }

    var body: some View {
        VStack(spacing: 64) {
            Spacer()
            StrokeAnimationShapeView(
                shape: HelloEnglishShape(),
                lineWidth: 8,
                lineColor: .white,
                duration: .seconds(3),
                shapeAspectRatio: HelloEnglishShape.aspectRatio,
                viewModel: .init(animationType: .progressiveDraw)
            )

            StrokeAnimationShapeView(
                shape: HelloJapaneseShape(),
                lineWidth: 8,
                lineColor: .white,
                duration: duration,
                shapeAspectRatio: HelloJapaneseShape.aspectRatio,
                viewModel: .init(animationType: .progressiveDraw)
            )
            Spacer()
        }
        .padding(24)
        .background(.slideBackgroundColor)
    }
}

#Preview {
    HelloAnimationView()
}
