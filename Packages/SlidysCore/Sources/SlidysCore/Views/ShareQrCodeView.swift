//
//  ShareQrCodeView.swift
//  SlidysCore
//
//  Created by Yugo Sugiyama on 2024/11/14.
//

import SwiftUI

public struct ShareQrCodeView: View {
    public init() {}

    public var body: some View {
        HStack(alignment: .center) {
            VStack(spacing: 0) {
                Text("Slidys")
                    .font(.system(size: 120, weight: .bold))
                Image(.appIcon)
                    .resizable()
                    .scaledToFit()
            }
            .padding(80)
            Image(.qrCode)
                .resizable()
                .scaledToFit()
                .border(.black)
        }
        .padding(20)
    }
}

#Preview {
    ShareQrCodeView()
}
