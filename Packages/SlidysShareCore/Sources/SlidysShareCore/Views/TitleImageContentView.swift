//
//  TitleImageContentView.swift
//  SlidysShareCore
//
//  Created by Claude on 2026/03/23.
//

import SwiftUI
import SlideKit
import SlidesCore

struct TitleImageContentView: View {
    let title: String
    let imageData: Data

    var body: some View {
        HeaderSlide(.init(title)) {
            if let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.slideBackgroundColor)
            }
        }
    }
}
