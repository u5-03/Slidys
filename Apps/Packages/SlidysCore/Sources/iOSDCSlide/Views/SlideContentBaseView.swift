//
//  SlideContentBaseView.swift
//
//
//  Created by Yugo Sugiyama on 2024/11/10.
//

import Foundation

import SwiftUI
import SlideKit

struct SlideContentBaseView: View {
    var body: some View {
        VStack(spacing: 0) {
            IntroductionSlide()
                .background(Color.red)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            Text("Hello, world!")
                .font(.system(size: 100))
                .background(Color.red)
            Spacer(minLength: 0)
        }
        .background(Color.purple)
    }
}

#Preview {
    SlideContentBaseView()
}
