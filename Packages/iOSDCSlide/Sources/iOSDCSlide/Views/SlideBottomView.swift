//
//  SlideBottomView.swift
//  iOSDC2024Slide
//
//  Created by Yugo Sugiyama on 2024/08/02.
//

import SwiftUI

struct SlideBottomView: View {
    private let autoScrollController = AutoScrollController(
        message: introductionSentence,
//        autoScrollType: .speed(speed: 1000)
        autoScrollType: .timer(duration: .seconds(300))
    )

    var body: some View {
        AutoScrollTextTimerView(controller: autoScrollController)
    }
}

#Preview {
    SlideBottomView()
}
