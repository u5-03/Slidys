//
//  LayoutComparisonSlide.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/11/06.
//

import SwiftUI
import SlideKit

struct TableData: Identifiable {
    var id: String {
        return leading + trailing
    }

    let leading: String
    let trailing: String
}

@Slide
struct LayoutComparisonSlide: View {
    let datas: [TableData] = [
        TableData(
            leading: "各SubviewのIDをhasChildに渡すことで、存在確認ができる",
            trailing: "各Subviewに明示的なIDが設定されていないので、厳密な存在確認は難しい"
        ),
        TableData(
            leading: "shouldRelayoutで再描画タイミングを明示的に指定可能",
            trailing: "Viewのライフサイクルや利用しているStateの変更タイミングに依存"
        ),
        TableData(
            leading: "親のContainerはLayoutBuilderなどで計算できるけど、Childを元にサイズを決定することはできない",
            trailing: "各Subviewのサイズ取得が可能\n→ Subviewサイズに合わせて、親のContainerのWidgetのサイズの指定が可能"
        ),
        TableData(
            leading: "childrenに渡した順にWidgetが重なるので、その順番で制御する必要がある",
            trailing: "zIndexのmodifierがあるので、z軸方向の順番の制御がしやすい"
        )
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("CustomMultiChildLayoutとLayout Protocolの比較")
                    .font(.mediumFont)
                    .padding()
                Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                    GridRow(alignment: .top) {
                        Group {
                            Text("CustomMultiChildLayout(Flutter)")
                                .font(.smallFont)
                                .lineLimit(1)
                                .minimumScaleFactor(0.01)
                            Color.defaultForegroundColor
                                .frame(width: 2)
                            Text("Layout Protocol(SwiftUI)")
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
                                .font(.smallFont)
                                .lineLimit(nil)
                                .minimumScaleFactor(0.01)
                                .gridColumnAlignment(.leading)
                            Color.defaultForegroundColor
                                .frame(width: 2)
                            Text(data.trailing)
                                .font(.smallFont)
                                .lineLimit(nil)
                                .minimumScaleFactor(0.01)
                                .gridColumnAlignment(.leading)
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

#Preview {
    SlidePreview {
        LayoutComparisonSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
