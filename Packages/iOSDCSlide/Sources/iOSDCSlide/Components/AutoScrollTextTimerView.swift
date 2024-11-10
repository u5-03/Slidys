//
//  AutoScrollTextTimerView.swift
//  iOSDC2024Slide
//
//  Created by Yugo Sugiyama on 2024/09/01.
//

import SwiftUI

public struct AutoScrollTextTimerView: View {
    private let controller: AutoScrollController

    public init(controller: AutoScrollController) {
        self.controller = controller
    }

    public var body: some View {
        HStack(spacing: 0) {
            Group {
                if let formatRemainingTime = controller.formattedTime() {
                    Text(formatRemainingTime)
                        .font(.system(size: 30, weight: .bold))
                        .minimumScaleFactor(0.1)
                        .frame(width: 80)
                } else {
                    Button(action: {
                        controller.startScrolling()
                    }, label: {
                        Image(systemName: "play")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .padding(4)
                    })
                }
            }
            .padding()
            // なぜかGeometryReaderがないと、レイアウトが大きく崩れる
            AutoScrollTextView(controller: controller)
        }
    }
}

//#Preview {
//    let controller = AutoScrollController(message: introductionSentence, autoScrollType: .timer(duration: .seconds(10)))
//    AutoScrollTextTimerView(controller: controller)
//}
