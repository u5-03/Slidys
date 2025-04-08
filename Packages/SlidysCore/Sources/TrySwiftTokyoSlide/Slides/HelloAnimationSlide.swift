//
//  Created by yugo.sugiyama on 2025/03/12
//  Copyright ©Sugiy All rights reserved.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct HelloAnimationSlide: View {
    @Phase var phase: SlidePhase
    enum SlidePhase: Int, PhasedState {
        case initial
        case overlay
    }

    var body: some View {
        ZStack {
            HelloAnimationView()
            if phase.isLast {
                Color.black.opacity(0.7)
                Text("How to implement with only SwiftUI?")
                    .font(.largeFont)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundStyle(.defaultForegroundColor)
            }
        }
    }
}

#Preview {
    SlidePreview {
        HelloAnimationSlide()
    }
}
