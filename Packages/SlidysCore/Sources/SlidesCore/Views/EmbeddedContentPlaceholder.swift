//
//  EmbeddedContentPlaceholder.swift
//  SlidesCore
//
//  Flutter の画面・動画・Web など、サムネイルや PDF 書き出しではそのまま描画できない
//  埋め込みコンテンツの代わりに出すダミー表示。`isSlideThumbnail` が true のときに使う。
//

import SwiftUI

public struct EmbeddedContentPlaceholder: View {
    let title: String
    let systemImage: String
    let caption: String

    public init(
        title: String,
        systemImage: String = "rectangle.dashed",
        caption: String = "発表時はここに実際の画面が表示されます"
    ) {
        self.title = title
        self.systemImage = systemImage
        self.caption = caption
    }

    public var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white.opacity(0.06))
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(style: StrokeStyle(lineWidth: 5, dash: [22, 16]))
                .foregroundStyle(.gray)
            VStack(spacing: 20) {
                Image(systemName: systemImage)
                    .font(.system(size: 110, weight: .light))
                Text(title)
                    .font(.system(size: 44, weight: .bold))
                Text(caption)
                    .font(.system(size: 28, weight: .regular))
                    .multilineTextAlignment(.center)
            }
            .foregroundStyle(.gray)
            .padding(32)
            .minimumScaleFactor(0.4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmbeddedContentPlaceholder(title: "Flutter デモ", systemImage: "iphone.gen3")
        .padding(40)
        .background(Color.slideBackgroundColor)
}
