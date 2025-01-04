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

enum SlideType: CaseIterable, Identifiable {
    case chibaSwift
    case kanagawaSwift
    case iosdcSlide

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
        }
    }

    @ViewBuilder
    public var view: some View {
        switch self {
        case .chibaSwift:
            ChibaSwiftSlideView()
        case .kanagawaSwift:
            KanagawaSwiftSlideView()
        case .iosdcSlide:
            iOSDCSlideView()
        }
    }
}

enum SlideSectionType: Identifiable, Hashable {
    case slides(SlideType)
    case info(InfoSectionType)

    var id: String {
        switch self {
        case .slides(let slideType):
            return slideType.id
        case .info(let infoSectionType):
            return infoSectionType.id
        }
    }

    @ViewBuilder
    var view: some View {
        switch self {
        case .slides(let slideType):
            slideType.view
        case .info(let infoSectionType):
            infoSectionType.view
        }
    }
}

struct ContentView: View {
    @State private var selectedSectionType: SlideSectionType?

    var body: some View {
        NavigationStack {
            List(selection: $selectedSectionType) {
                Section("Slides") {
                    ForEach(SlideType.allCases) { type in
                        Text(type.displayValue)
                            .padding()
                            .tag(SlideSectionType.slides(type))
                    }
                }
                Section("Other") {
                    ForEach(InfoSectionType.allCases) { type in
                        Text(type.displayValue)
                            .padding()
                            .tag(SlideSectionType.info(type))
                    }
                }
            }
            .listRowBackground(Color.clear)
            .navigationTitle("Slidys")
        }
        .sheet(item: $selectedSectionType) { type in
            ZStack(alignment: .topTrailing) {
                type.view
                    .frame(width: 800, height: 450)
                closeButton
            }
        }
    }

    var closeButton: some View {
        Button(action: {
            selectedSectionType = nil
        }) {
            Circle()
                .strokeBorder(Color.gray, lineWidth: 2)
                .background(Image(systemName: "xmark").foregroundStyle(.gray))
                .frame(width: 24, height: 24)
                .padding(.all, 4)

        }
    }
}



#Preview {
    ContentView()
}
