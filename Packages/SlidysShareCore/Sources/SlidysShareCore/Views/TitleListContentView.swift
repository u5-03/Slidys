//
//  TitleListContentView.swift
//  SlidysShareCore
//
//  Created by Claude on 2026/03/23.
//

import SwiftUI
import SlideKit
import SlidesCore

struct TitleListContentView: View {
    let title: String
    let items: [ListItem]

    var body: some View {
        HeaderSlide(.init(title)) {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    HStack(alignment: .top, spacing: 12) {
                        if item.isIndented {
                            Spacer()
                                .frame(width: 60)
                        }
                        Text("\(index + 1).")
                            .font(.system(size: 48, weight: .regular))
                        Text(item.text)
                            .font(.system(size: 48, weight: .regular))
                    }
                    .foregroundStyle(.defaultForegroundColor)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
    }
}
