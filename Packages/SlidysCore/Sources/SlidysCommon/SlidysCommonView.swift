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
import MinokamoSwiftSlide
import GoToNextPlatformSlide
import TrySwiftTokyoSlide
import NagoyaSwiftSlide
import iOSDC2025Slide
import HakodateSwiftSlide
import iOSDC2026Slide

public protocol SlideTypeProtocol: CaseIterable, Identifiable, Codable, Equatable, Hashable {
    var id: String { get }
    var displayValue: String { get }
    var view: any SlideViewProtocol { get }
}

public enum SlideType: SlideTypeProtocol {
    case iosdcSlide
    case chibaSwift
    case kanagawaSwift
    case osakaSwift
    case minokamoSwift
    case goToNextPlatform
    case trySwiftTokyo
    case nagoyaSwift
    case iOSDC2025
    case hakodateSwift
    case iOSDC2026

    public static let slideWindowKey = "SlideWindowKey"

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
        case .minokamoSwift:
            return "Mimokamo.swift #1"
        case .goToNextPlatform:
            return "突撃！隣のモバイルプラットフォーム！"
        case .trySwiftTokyo:
            return "try! Swift Tokyo2025"
        case .iosdcSlide:
            return "iOSDC2024"
        case .nagoyaSwift:
            return "Nagoya.swift#1"
        case .iOSDC2025:
            return "iOSDC2025"
        case .hakodateSwift:
            return "Hakodate.swift #1"
        case .iOSDC2026:
            return "iOSDC2026"
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
        case .minokamoSwift:
            MinokamoSwiftSlideView()
        case .goToNextPlatform:
            GoToNextPlatformSlideView()
        case .trySwiftTokyo:
            TrySwiftTokyoSlideView()
        case .iosdcSlide:
            iOSDCSlideView()
        case .nagoyaSwift:
            NagoyaSwiftSlideView()
        case .iOSDC2025:
            iOSDC2025SlideView()
        case .hakodateSwift:
            HakodateSwiftSlideView()
        case .iOSDC2026:
            iOSDC2026SlideView()
        }
    }
}

public enum SlideSectionType: Equatable {
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

/// 長押しメニューから PDF 書き出しを頼まれたデッキ
struct PDFExportRequest: Identifiable {
    let id: String
    let source: SlidePDFExportSource
}

public struct SlidysCommonView: View {
    @State private var selectedSectionType: SlideSectionType?
    @State private var pdfExportRequest: PDFExportRequest?
    @Environment(\.openWindow) private var openWindow

    private let slideTypes: [any SlideTypeProtocol]

    public init(slideTypes: [any SlideTypeProtocol]) {
        self.slideTypes = slideTypes
    }

    public var body: some View {
        GeometryReader { proxy in
            NavigationStack {
                List(selection: $selectedSectionType) {
                    Section("Slides") {
                        ForEach(slideTypes, id: \.id) { type in
                            Text(type.displayValue)
                                .padding()
                                .tag(SlideSectionType.slides(type))
                                // 長押し(macOS は右クリック)で PDF 書き出し。対応デッキ(pdfExportSource を返すもの)だけ出す
                                .contextMenu {
                                    if let source = type.view.pdfExportSource {
                                        Button {
                                            pdfExportRequest = PDFExportRequest(id: type.id, source: source)
                                        } label: {
                                            Label("PDFを書き出す", systemImage: "doc.richtext")
                                        }
                                    }
                                }
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
                .sheet(item: $pdfExportRequest) { request in
                    PDFExportSheet(source: request.source)
                }
            }
#if os(macOS)
            .sheet(item: $selectedSectionType) { type in
                ZStack(alignment: .topTrailing) {
                    let size = proxy.size
                    type.view
                        .frame(width: size.width, height: size.height)
                    closeButton
                        .padding()
                }
            }
#elseif os(iOS)
            .fullScreenCover(item: $selectedSectionType) { type in
                switch type {
                case .slides:
                    // 閉じる操作は SlideBaseView の発表者メニュー(ナビゲーションバー)に統合されている。
                    // NavigationStack に載せるのは、iPhone Duo のようにバーが縦向き(画面端)に出る端末でも
                    // システムが適切な位置へ配置してくれるため(機種別の分岐が不要)。
                    NavigationStack {
                        AnyView(type.view)
                            .environment(\.slideCloseAction) { selectedSectionType = nil }
                    }
                case .info:
                    ZStack(alignment: .topTrailing) {
                        type.view
                        closeButton
                            .padding()
                    }
                }
            }
#elseif os(visionOS)
            .onChange(of: selectedSectionType) { _, newValue in
                switch newValue {
                case .slides(let slideType):
                    openWindow(id: SlideType.slideWindowKey, value: slideType)
                case .info(let infoSectionType):
                    openWindow(id: InfoSectionType.infoSectionWindowKey, value: infoSectionType)
                case nil:
                    break
                }
                selectedSectionType = nil
            }
#endif
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

