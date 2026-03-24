//
//  Created by yugo.sugiyama on 2025/04/20
//  Copyright ©Sugiy All rights reserved.
//

import SwiftUI

public struct PixelImageSettingView: View {

    let imageResource: ImageResource
    @State private var pixels: [Pixel] = []
    @State private var isBlurred: Bool
    @State private var dimension: Int
    @State private var blurDistance: Int
    @State private var task: Task<Void, Never>?

    public init(imageResource: ImageResource, isBlurred: Bool = false, dimension: Int = 50, blurDistance: Int = 5) {
        self.imageResource = imageResource
        self.isBlurred = isBlurred
        self.dimension = dimension
        self.blurDistance = blurDistance
    }

    public var body: some View {
        ViewThatFits {
            HStack {
                PixelImageView(
                    pixels: pixels,
                    dimension: dimension,
                    isBlurred: isBlurred,
                    blurDistance: blurDistance
                )
                .id(dimension)
                .padding()
                settingView
            }
            .frame(minWidth: 600)
            VStack {
                PixelImageView(
                    pixels: pixels,
                    dimension: dimension,
                    isBlurred: isBlurred,
                    blurDistance: blurDistance
                )
                .id(dimension)
                .padding()
                settingView
            }
        }
        .padding(.top, 60)
        .onAppear {
            task?.cancel()
            task = Task {
                await loadImageResourceAndConvert()
            }
        }
        // 変換サイズ変更時に再変換する
        .onChange(of: dimension) { _, _ in
            task?.cancel()
            task = Task {
                await loadImageResourceAndConvert()
            }
        }
    }

    /// Bundle 内の画像ファイルから ImageResource を生成し、ピクセル配列を作成する
    private func loadImageResourceAndConvert() async {
        let newSize = CGSize(width: dimension, height: dimension)
        let convertedPixels = await convertImageResourceToPixels(resource: imageResource, size: newSize)
        self.pixels = convertedPixels
    }
}

private extension PixelImageSettingView {
    var settingView: some View {
        VStack {
            // 変換サイズのPicker
            HStack {
                Text("Image Size:")
                Picker("", selection: $dimension) {
                    Text("50").tag(50)
                    Text("100").tag(100)
                    Text("150").tag(150)
                    Text("200").tag(200)
                }
                .pickerStyle(.segmented)
            }
            .padding(.horizontal)

            // ブラーのサンプリング範囲のSlider
            HStack {
                Text("Blur Range:")
                Picker("", selection: $blurDistance) {
                    Text("1").tag(1)
                    Text("3").tag(3)
                    Text("5").tag(5)
                    Text("8").tag(8)
                    Text("10").tag(10)
                    Text("20").tag(20)
                }
                .pickerStyle(.segmented)
            }
            .padding(.horizontal)
            Toggle(isOn: $isBlurred) {
                Text("Blur を適用")
            }
            .padding()
        }
        .padding(.top)
    }
}

#Preview {
    PixelImageSettingView(imageResource: .icon, dimension: 50)
}
