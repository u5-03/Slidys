//
//  CloseButtonView.swift
//  SlidysCore
//
//  Created by yugo.sugiyama on 2025/01/11.
//

import SwiftUI

public struct CloseButtonView: View {
    @Environment(\.dismiss) var dismiss
    
    public init() {}
    
    public var body: some View {
        Button(action: {
            dismiss()
        }) {
            Circle()
                .strokeBorder(Color.gray, lineWidth: 2)
                .background(
                    Image(systemName: "xmark")
                        .foregroundStyle(.gray)
                )
                .clipShape(Circle())
                .frame(width: 24, height: 24)
                .padding(.all, 4)

        }
    }
}

#Preview {
    CloseButtonView()
}
