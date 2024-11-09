//
//  CodeSlide.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/10/27.
//

import SwiftUI
import SlideKit

@Slide
struct CodeSlide: View {
    let title: String
    let code: String
    let fontSize: CGFloat

    init(title: String, code: String, fontSize: CGFloat = 40) {
        self.title = title
        self.code = code
        self.fontSize = fontSize
    }

    var body: some View {
        HeaderSlide(LocalizedStringKey(title)) {
            Code(code,
                 colorTheme: .defaultDark,
                 fontSize: fontSize
            )
        }
    }
}

#Preview {
    SlidePreview {
        CodeSlide(
            title: "実際のコード1",
            code: Constants.strokeAnimationShapeViewCode,
            fontSize: 38
        )
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}


