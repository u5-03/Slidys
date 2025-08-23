//
//  Created by yugo.sugiyama on 2025/04/20
//  Copyright ©Sugiy All rights reserved.
//

import Algorithms
import CoreGraphics
import DeveloperToolsSupport
import SwiftUI

/// グリッド上にピクセルを描画するビュー
/// - Note: columns/rows は変換サイズと一致している必要があります。
struct PixelImageView: View {
    let pixels: [Pixel]
    let dimension: Int
    let isBlurred: Bool
    let blurDistance: Int  // 周囲ピクセルのサンプリング範囲
    let weight: Double = 0.03  // 重み係数(固定)

    var body: some View {
        GeometryReader { geometry in
            let pixelSize = geometry.size.width / CGFloat(dimension)
            let gridItems = Array(
                repeating: GridItem(.fixed(pixelSize), spacing: 0), count: dimension)

            LazyVGrid(columns: gridItems, spacing: 0) {
                ForEach(pixels.indexed(), id: \.index) { (index, pixel) in
                    if isBlurred {
                        BlurredPixelView(
                            index: index,
                            weight: weight,
                            dimension: dimension,
                            blurDistance: blurDistance,
                            pixel: pixel,
                            pixels: pixels
                        )
                        .id(index)
                        .frame(width: pixelSize, height: pixelSize)
                    } else {
                        PixelView(pixel: pixel)
                            .frame(width: pixelSize, height: pixelSize)
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var pixels: [Pixel] = []
    @Previewable @State var isBlurred = true
    @Previewable @State var dimension = 50
    @Previewable @State var blurDistance = 2

    PixelImageView(
        pixels: pixels,
        dimension: dimension,
        isBlurred: isBlurred,
        blurDistance: blurDistance
    )
    .task {
        let newSize = CGSize(width: dimension, height: dimension)
        let convertedPixels = await convertImageResourceToPixels(resource: .icon, size: newSize)
        pixels = convertedPixels
    }
}
