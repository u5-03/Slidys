//
//  ShareQrCodeView.swift
//  SlidysCore
//
//  Created by Yugo Sugiyama on 2024/11/14.
//

import SwiftUI

public enum QrCodeType {
    case native
    case flutter
    case all

    @ViewBuilder
    var view: some View {
        switch self {
        case .native:
            Image(.qrCodeTestFlight)
                .resizable()
                .scaledToFit()
        case .flutter:
            Image(.qrCodeTestFlightFlutter)
                .resizable()
                .scaledToFit()
        case .all:
            AnyView(
                HStack {
                    VStack {
                        Text("Slidys")
                            .font(.mediumFont)
                        QrCodeType.native.view
                    }
                    VStack {
                        Text("Slidys for Flutter")
                            .font(.mediumFont)
                        QrCodeType.flutter.view
                    }
                }
            )
        }
    }
}

public struct ShareQrCodeView: View {
    public init() {}

    public var body: some View {
        QrCodeType.all.view
            .frame(maxHeight: .infinity)
            .padding(20)
    }
}

#Preview {
    ShareQrCodeView()
}
