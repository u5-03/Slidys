//
//  SlidysCommonView.swift
//  SlidysCore
//
//  Created by Yugo Sugiyama on 2025/01/04.
//

import SwiftUI
import SlidesCore
import iOSDCSlide
import ChibaSwiftSlide
import KanagawaSwiftSlide
import OsakaSwiftSlide

public protocol SlideTypeProtocol: CaseIterable, Identifiable {
    var id: String { get }
    var displayValue: String { get }
    var view: any SlideViewProtocol { get }
}

public enum SlideType: SlideTypeProtocol {
    case chibaSwift
    case kanagawaSwift
    case osakaSwift
    case iosdcSlide

    public var id: String {
        return displayValue
    }

    public var displayValue: String {
        switch self {
        case .chibaSwift:
            return "Chiba.swift #1"
        case .kanagawaSwift:
            return "Kanagawa.swift #1"
        case .osakaSwift:
            return "Osaka.swift #1"
        case .iosdcSlide:
            return "iOSDC2024"
        }
    }

    public var view: any SlideViewProtocol {
        switch self {
        case .chibaSwift:
            ChibaSwiftSlideView()
        case .kanagawaSwift:
            KanagawaSwiftSlideView()
        case .osakaSwift:
            OsakaSwiftSlideView()
        case .iosdcSlide:
            iOSDCSlideView()
        }
    }
}

public enum SlideSectionType {
    case slides(any SlideTypeProtocol)
    case info(InfoSectionType)

    public var id: String {
        switch self {
        case .slides(let slideType):
            return slideType.id
        case .info(let infoSectionType):
            return infoSectionType.id
        }
    }

    @ViewBuilder
    public var view: some View {
        switch self {
        case .slides(let slideType):
            AnyView(slideType.view)
        case .info(let infoSectionType):
            infoSectionType.view
        }
    }
}

extension SlideSectionType: Identifiable, Hashable  {
    public static func == (lhs: SlideSectionType, rhs: SlideSectionType) -> Bool{
        switch (lhs, rhs) {
        case (.slides(let slideTypeLhs), .slides(let slideTypeRhs)):
            return slideTypeLhs.id == slideTypeRhs.id
        case (.info(let infoSectionTypeLhs), .info(let infoSectionTypeRhs)):
            return infoSectionTypeLhs.id == infoSectionTypeRhs.id
        default:
            return false
        }
    }

    public func hash(into hasher: inout Hasher) {
       switch self {
       case .slides(let slideType):
           hasher.combine(slideType.id)
       case .info(let infoSectionType):
           hasher.combine(infoSectionType.id)
       }
   }
}

public struct SlidysCommonView: View {
    @State private var selectedSectionType: SlideSectionType?
    private let slideTypes: [any SlideTypeProtocol]

    public init(slideTypes: [any SlideTypeProtocol]) {
        self.slideTypes = slideTypes
    }

    public var body: some View {
        NavigationStack {
            List(selection: $selectedSectionType) {
                Section("Slides") {
                    ForEach(slideTypes, id: \.id) { type in
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
                Section("App Info") {
                    Text(appVersionAndBuildNumber)
                }
            }
            .listRowBackground(Color.clear)
            .navigationTitle("Slidys")
        }
#if os(macOS)
        .sheet(item: $selectedSectionType) { type in
            ZStack(alignment: .topTrailing) {
                type.view
                    .frame(width: 800, height: 450)
                closeButton
                    .padding()
            }
        }
#elseif os(iOS)
        .fullScreenCover(item: $selectedSectionType) { type in
            ZStack(alignment: .topTrailing) {
                type.view
                closeButton
                    .padding()
            }
        }
#endif
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
        .buttonStyle(.borderless)
    }
}

private extension SlidysCommonView {
    var appVersionAndBuildNumber: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"

        return "v\(version)(\(build))"
    }

}



#Preview {
    SlidysCommonView(slideTypes: SlideType.allCases)
}

