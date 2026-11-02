//
//  SlideViewProtocol.swift
//  SlidysCore
//
//  Created by Yugo Sugiyama on 2025/01/04.
//

import SwiftUI

public protocol SlideViewProtocol: View {
    /// PDF 書き出しに使うスライド一式。対応していないデッキは nil(既定)。
    @MainActor var pdfExportSource: SlidePDFExportSource? { get }
}

public extension SlideViewProtocol {
    @MainActor var pdfExportSource: SlidePDFExportSource? { nil }
}
