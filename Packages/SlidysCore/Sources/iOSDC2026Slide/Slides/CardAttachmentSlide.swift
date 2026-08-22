//
//  CardAttachmentSlide.swift
//  iOSDC2026Slide
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct CardAttachmentSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("SwiftUI製のカードを3D空間に置く") {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    Text("カードのビジュアル(枠・ステータス・ホログラム風光沢)はSwiftUIで作り込み、RealityViewのAttachmentで空間に配置")
                        .font(.regularFont)
                    Text("手札・ドロー中カード・配置済みカード、すべて実体はSwiftUIのView")
                        .font(.regularFont)

                    Text("落とし穴: Attachmentは背面から見ると内容が鏡写しに透けて見える")
                        .font(.regularFont)
                        .padding(.top, 10)

                    CodeBlockView(
                        """
                        // 裏面デザインのViewを一度だけラスタライズしてテクスチャ化し、
                        // Attachmentの背面(-Z)に貼った板で覆う
                        let renderer = ImageRenderer(content: CardBackView().frame(width: 236, height: 344))
                        renderer.scale = 3
                        let texture = try? TextureResource(
                            image: renderer.cgImage!, options: .init(semantic: .color)
                        )
                        """)

                    Text("既存のSwiftUI資産を空間アプリへ持ち込む近道になるテクニック")
                        .font(.regularFont)
                        .padding(.top, 10)
                }
            }
        }
    }
}

#Preview {
    SlidePreview {
        CardAttachmentSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
