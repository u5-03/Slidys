//
//  OutlinedTextView.swift
//  SlidysCore
//
//  Created by yugo.sugiyama on 2025/02/19.
//

import SwiftUI

struct OutlinedTextView: View {
    let text: String
    let fontSize: CGFloat
    let textColor: Color
    let outlineColor: Color
    let outlineWidth: CGFloat

    var body: some View {
        ZStack {
            ForEach([-1, 1], id: \.self) { x in
                ForEach([-1, 1], id: \.self) { y in
                    Text(text)
                        .font(.system(size: fontSize, weight: .bold))
                        .foregroundColor(outlineColor)
                        .offset(x: CGFloat(x) * outlineWidth, y: CGFloat(y) * outlineWidth)
                }
            }

            Text(text)
                .font(.system(size: fontSize, weight: .bold))
                .foregroundColor(textColor)
        }
    }
}
