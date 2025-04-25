//
//  Created by yugo.sugiyama on 2025/04/20
//  Copyright ©Sugiy All rights reserved.
//

import SwiftUI

struct BlurredPixelView: View {
    let index: Int
    let weight: Double  // 周囲ピクセルの寄与度
    let dimension: Int
    let blurDistance: Int
    let pixel: Pixel
    let pixels: [Pixel]

    @State private var adjustedColor: Color?
//    @State private var surroundingPixels: [Pixel] = []

    var body: some View {
//        let _ = print("Build BlurredPixelView \(index)")
        Group {
            if let adjustedColor {
                Rectangle()
                    .fill(adjustedColor)
                    .aspectRatio(1, contentMode: .fit)
            } else {
                Color.clear.opacity(0.0001)
                    .aspectRatio(1, contentMode: .fit)
            }
        }
        .task {
//            print("Task BlurredPixelView \(index) Before")
            let surroundingPixels = await getSurroundingPixels(for: pixel)
//            print("Task BlurredPixelView \(index)")
            adjustedColor = computeBlurredColor(surroundingPixels: surroundingPixels)
//            print("Task BlurredPixelView \(index), color: \(adjustedColor)")
        }
    }
}

private extension BlurredPixelView {
    func getSurroundingPixels(for pixel: Pixel) async -> [Pixel] {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                var neighbors: [Pixel] = []
                let col = pixel.index % dimension
                let row = pixel.index / dimension

                for dy in -blurDistance...blurDistance {
                    for dx in -blurDistance...blurDistance {
                        if dx == 0 && dy == 0 { continue }
                        let newCol = col + dx
                        let newRow = row + dy
                        if newCol >= 0, newCol < dimension, newRow >= 0, newRow < dimension {
                            let neighborIndex = newRow * dimension + newCol
                            if neighborIndex < pixels.count {
                                neighbors.append(pixels[neighborIndex])
                            }
                        }
                    }
                }

                continuation.resume(returning: neighbors)
            }
        }
    }

    func computeBlurredColor(surroundingPixels: [Pixel]) -> Color {
        let baseRed = Double(pixel.r) / 255.0
        let baseGreen = Double(pixel.g) / 255.0
        let baseBlue = Double(pixel.b) / 255.0

        var rTotal = baseRed
        var gTotal = baseGreen
        var bTotal = baseBlue
        var totalWeight = 1.0

        for neighbor in surroundingPixels {
            let nRed = Double(neighbor.r) / 255.0
            let nGreen = Double(neighbor.g) / 255.0
            let nBlue = Double(neighbor.b) / 255.0
            rTotal += nRed * weight
            gTotal += nGreen * weight
            bTotal += nBlue * weight
            totalWeight += weight
        }
        return Color(
            red: rTotal / totalWeight,
            green: gTotal / totalWeight,
            blue: bTotal / totalWeight
        )
    }
}
