//
//  Created by yugo.sugiyama on 2025/04/20
//  Copyright ©Sugiy All rights reserved.
//

import CoreGraphics
import DeveloperToolsSupport
import Foundation

#if canImport(AppKit)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif

func convertImageResourceToPixels(
    resource: ImageResource,
    size: CGSize = CGSize(width: 100, height: 100)
) async -> [Pixel] {
    await withCheckedContinuation { continuation in
        DispatchQueue.global(qos: .userInitiated).async {
            var pixels: [Pixel] = []
            let image = AppImage(resource: resource)
            // ImageResource から CGImage を取得
            guard let cgImage = image.asCgImage else {
                continuation.resume(returning: [])
                return
            }
            let width = Int(size.width)
            let height = Int(size.height)
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let bytesPerPixel = 4
            let bitsPerComponent = 8
            let bytesPerRow = bytesPerPixel * width
            var pixelData = [UInt8](repeating: 0, count: height * bytesPerRow)

            // CGContext を作成してリサイズ後の画像を描画
            guard
                let context = CGContext(
                    data: &pixelData,
                    width: width,
                    height: height,
                    bitsPerComponent: bitsPerComponent,
                    bytesPerRow: bytesPerRow,
                    space: colorSpace,
                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
                )
            else {
                print("コンテキストの作成に失敗しました")
                continuation.resume(returning: [])
                return
            }

            context.draw(cgImage, in: CGRect(origin: .zero, size: size))

            // 各ピクセルを読み出す(左上から右下へ順次)
            var currentIndex = 0
            for y in 0..<height {
                for x in 0..<width {
                    let offset = (y * bytesPerRow) + (x * bytesPerPixel)
                    let r = pixelData[offset + 0]
                    let g = pixelData[offset + 1]
                    let b = pixelData[offset + 2]
                    let a = pixelData[offset + 3]

                    // 完全に透明なら (0, 0, 0)
                    if a == 0 {
                        pixels.append(Pixel(index: currentIndex, r: 0, g: 0, b: 0))
                    } else {
                        pixels.append(Pixel(index: currentIndex, r: Int(r), g: Int(g), b: Int(b)))
                    }
                    currentIndex += 1
                }
            }
            continuation.resume(returning: pixels)
        }
    }
}
