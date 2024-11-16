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
        GeometryReader { proxy in
            HStack(alignment: .center) {
                VStack(spacing: 0) {
                    Text("Slidys")
                        .font(.system(size: 120, weight: .bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.1)
                    Image(.appIcon)
                        .resizable()
                        .scaledToFit()
                }
                .frame(width: proxy.size.width / 2, alignment: .center)
                Image(.qrCode)
                    .resizable()
                    .scaledToFit()
                    .border(.black)
                    .frame(width: proxy.size.width / 2)
            }
            .frame(maxHeight: .infinity)
        }
        .padding(20)
    }
}

#Preview {
    ShareQrCodeView()
}
