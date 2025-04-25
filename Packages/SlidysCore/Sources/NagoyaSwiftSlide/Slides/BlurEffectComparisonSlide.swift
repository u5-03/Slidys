//
//  Created by yugo.sugiyama on 2025/04/19
//  Copyright ©Sugiy All rights reserved.
//

import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct BlurEffectComparisonSlide: View {
    let datas: [TableTripleData] = [
        TableTripleData(
            leading: "基本実装",
            center: "UIVisualEffectView /  UIBlurEffect(style:)",
            trailing: "blur(radius:) / Material"
        ),
        TableTripleData(
            leading: "使い方",
            center: """
let blur = UIBlurEffect(style: .light)
let view = UIVisualEffectView(effect: blur)
""",
            trailing: """
.blur(radius: 10)
background(.regularMaterial)
"""
        ),
        TableTripleData(
            leading: "選べるスタイル",
            center: ".light, .dark, .extraLight, .system* 系",
            trailing: ".ultraThinMaterial, .regularMaterial, .thick*"
        ),
        TableTripleData(
            leading: "主な使い所",
            center: "iOS 8 以降で広く使われる\nカスタムViewに組み込みやすい",
            trailing: "iOS13(一部iOS15~)以降で正式対応。\n宣言的に簡単に使える"
        ),
        TableTripleData(
            leading: "パフォーマンス",
            center: "UIVisualEffectView は内部で最適化済\n効率よく使えば軽量",
            trailing: "Material は Metal ベースで軽量。\nただし重ねすぎ注意"
        ),
    ]
    
    var body: some View {
        HeaderSlide("Apple PlatformでのBlurの実装方法") {
            GeometryReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                            GridRow(alignment: .top) {
                                Group {
                                    Text("")
                                        .font(.smallFont)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.01)
                                    Color.defaultForegroundColor
                                        .frame(width: 2)
                                    Text("UIKit")
                                        .font(.smallFont)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.01)
                                    Color.defaultForegroundColor
                                        .frame(width: 2)
                                    Text("SwiftUI")
                                        .font(.smallFont)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.01)
                                }
                                .padding()
                            }
                            Divider()
                                .frame(height: 4)
                                .background(.defaultForegroundColor)
                            ForEach(datas) { data in
                                GridRow(alignment: .top) {
                                    Text(data.leading)
                                        .minimumScaleFactor(0.0001)
                                        .font(.tinyFont)
                                        .lineLimit(nil)
                                        .gridColumnAlignment(.leading)
                                    Color.defaultForegroundColor
                                        .frame(width: 2)
                                    Text(data.center)
                                        .font(.smallFont)
                                        .lineLimit(nil)
                                        .minimumScaleFactor(0.01)
                                        .gridColumnAlignment(.leading)
                                        .frame(width: proxy.size.width * 0.38, alignment: .leading)
                                    Color.defaultForegroundColor
                                        .frame(width: 2)
                                    Text(data.trailing)
                                        .font(.smallFont)
                                        .lineLimit(nil)
                                        .minimumScaleFactor(0.01)
                                        .gridColumnAlignment(.leading)
                                        .frame(width: proxy.size.width * 0.38, alignment: .leading)
                                }
                                .padding(.horizontal)
                                Divider()
                                    .background(.defaultForegroundColor)
                            }
                        }
                        .padding()
                    }
                    .frame(maxHeight: .infinity)
                    .foregroundStyle(.defaultForegroundColor)
                    .background(.slideBackgroundColor)
                }
            }
        }
    }
}

#Preview {
    SlidePreview {
        BlurEffectComparisonSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}


