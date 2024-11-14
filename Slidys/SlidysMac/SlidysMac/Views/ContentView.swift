//
//  ContentView.swift
//  SlidysMac
//
//  Created by Yugo Sugiyama on 2024/11/10.
//

import SwiftUI
import ChibaSwiftSlide
import KanagawaSwiftSlide
import iOSDCSlide
import SlidysCore

enum SlideType: CaseIterable, Identifiable, Equatable {
    case chibaSwift
    case kanagawaSwift
    case iosdcSlide
    case share

    var id: String {
        return displayValue
    }

    var displayValue: String {
        switch self {
        case .chibaSwift:
            return "Chiba.swift #1"
        case .kanagawaSwift:
            return "Kanagawa.swift #1"
        case .iosdcSlide:
            return "iOSDC2024"
        case .share:
            return "Share Page"
        }
    }
}

struct ContentView: View {
    @State private var selectedItem: SlideType?
    @Environment(\.openWindow) var openWindow

    var body: some View {
        NavigationStack {
            List(SlideType.allCases, selection: $selectedItem) { item in
                Text(item.displayValue)
                    .padding()
                    .tag(item)
            }
            .navigationTitle("Slidys")
        }
        .sheet(item: $selectedItem) { type in
            ZStack(alignment: .topTrailing) {
                switch type {
                case .chibaSwift:
                    ChibaSwiftSlideView()
                case .kanagawaSwift:
                    KanagawaSwiftSlideView()
                case .iosdcSlide:
                    iOSDCSlideView()
                case .share:
                    ShareQrCodeView()
                }
                closeButton
            }
            .frame(width: 800, height: 450)
        }
    }

    var closeButton: some View {
        Button(action: {
            selectedItem = nil
        }) {
            Image(systemName: "xmark")
                .foregroundStyle(.white)
                .background(.clear)
                .frame(width: 50, height: 50)
        }
    }
}



#Preview {
    ContentView()
}
