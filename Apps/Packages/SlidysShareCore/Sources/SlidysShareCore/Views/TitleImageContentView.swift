//
//  TitleImageContentView.swift
//  SlidysShareCore
//
//  Created by Claude on 2026/03/23.
//

import SwiftUI
import SlideKit
import SlidesCore
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

struct TitleImageContentView: View {
    let title: String
    let imageData: Data

    var body: some View {
        HeaderSlide(.init(title)) {
            if let image = platformImage(from: imageData) {
                image
                    .resizable()
                    .scaledToFit()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.slideBackgroundColor)
            }
        }
    }

    private func platformImage(from data: Data) -> Image? {
        #if canImport(UIKit)
        guard let uiImage = UIImage(data: data) else { return nil }
        return Image(uiImage: uiImage)
        #elseif canImport(AppKit)
        guard let nsImage = NSImage(data: data) else { return nil }
        return Image(nsImage: nsImage)
        #endif
    }
}
