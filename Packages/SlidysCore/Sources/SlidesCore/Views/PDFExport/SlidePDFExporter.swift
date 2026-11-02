//
//  SlidePDFExporter.swift
//  SlidesCore
//
//  デッキを PDF に書き出す。SlideKit の SlidePDFExporter(macOS 専用)と同じ方式で、
//  各スライドを ImageRenderer で PDF コンテキストに描画する。iOS / macOS 両対応。
//  - フェーズ付きスライドは全項目を表示した状態で 1 ページにする(revealsAllPhases)
//  - Flutter の画面・動画・RealityView などは isSlideThumbnail でプレースホルダーに置き換える
//    (UIKit / AppKit のコンポーネントは ImageRenderer で描画できないため)
//

import SlideKit
import SwiftUI

/// PDF 書き出しに必要な情報。各デッキの View(SlideViewProtocol)が `pdfExportSource` で返す。
public struct SlidePDFExportSource {
    public let slides: [any Slide]
    public let slideTheme: CustomSlideTheme
    public let slideSize: CGSize
    /// 拡張子なしのファイル名
    public let fileName: String

    public init(
        slides: [any Slide],
        slideTheme: CustomSlideTheme,
        slideSize: CGSize = SlideSize.standard16_9,
        fileName: String
    ) {
        self.slides = slides
        self.slideTheme = slideTheme
        self.slideSize = slideSize
        self.fileName = fileName
    }
}

public enum SlidePDFExportError: LocalizedError {
    case contextCreationFailed

    public var errorDescription: String? {
        switch self {
        case .contextCreationFailed: return "PDF の作成に失敗しました"
        }
    }
}

@MainActor
public enum SlidePDFExporter {
    /// 一時ディレクトリに PDF を書き出して URL を返す。
    /// - Parameter progress: (完了ページ数, 総ページ数) を受け取る進捗コールバック
    public static func export(
        _ source: SlidePDFExportSource,
        progress: @escaping @MainActor (Int, Int) -> Void = { _, _ in }
    ) async throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(source.fileName).pdf")
        try? FileManager.default.removeItem(at: url)

        var mediaBox = CGRect(origin: .zero, size: source.slideSize)
        guard let consumer = CGDataConsumer(url: url as CFURL),
              let context = CGContext(consumer: consumer, mediaBox: &mediaBox, nil) else {
            throw SlidePDFExportError.contextCreationFailed
        }

        let total = source.slides.count
        for (index, slide) in source.slides.enumerated() {
            let page = AnyView(slide)
                .environment(\.isSlideThumbnail, true)
                .environment(\.revealsAllPhases, true)
                .slideTheme(source.slideTheme)
                .foregroundColor(.black)
                .background(.white)
                .frame(width: source.slideSize.width, height: source.slideSize.height)
                // ページ番号(発表時の CustomIndexStyle と同じ見た目)。SlideRouterView を通さないので自前で描く
                .overlay(alignment: .bottomTrailing) {
                    Text("\(index + 1) / \(total)")
                        .foregroundColor(.gray)
                        .font(.system(size: 30))
                        .padding()
                }
            let renderer = ImageRenderer(content: page)
            renderer.proposedSize = ProposedViewSize(source.slideSize)
            renderer.render { size, render in
                let options: [CFString: Any] = [kCGPDFContextMediaBox: CGRect(origin: .zero, size: size)]
                context.beginPDFPage(options as CFDictionary)
                render(context)
                context.endPDFPage()
            }
            progress(index + 1, total)
            // 進捗表示を更新する隙間を作る
            await Task.yield()
        }
        context.closePDF()
        return url
    }
}

/// PDF 書き出しの進捗と結果(共有 / 保存)を出すシート。
public struct PDFExportSheet: View {
    let source: SlidePDFExportSource
    @State private var done = 0
    @State private var total = 0
    @State private var resultURL: URL?
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss

    public init(source: SlidePDFExportSource) {
        self.source = source
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                if let resultURL {
                    Image(systemName: "doc.richtext")
                        .font(.system(size: 64))
                        .foregroundStyle(.secondary)
                    Text("\(source.fileName).pdf(\(total) ページ)")
                        .font(.headline)
                    ShareLink(item: resultURL) {
                        Label("共有 / ファイルに保存", systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(.borderedProminent)
#if os(macOS)
                    Button("Finder で表示") {
                        NSWorkspace.shared.activateFileViewerSelecting([resultURL])
                    }
#endif
                } else if let errorMessage {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 64))
                        .foregroundStyle(.orange)
                    Text(errorMessage)
                } else {
                    ProgressView(value: Double(done), total: Double(max(total, 1)))
                        .frame(maxWidth: 320)
                    Text(total == 0 ? "準備中…" : "\(done) / \(total) ページを書き出し中…")
                        .foregroundStyle(.secondary)
                }
            }
            .padding(32)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("PDF を書き出す")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
        .task {
            total = source.slides.count
            do {
                resultURL = try await SlidePDFExporter.export(source) { finished, all in
                    done = finished
                    total = all
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
#if os(macOS)
        .frame(minWidth: 480, minHeight: 320)
#endif
    }
}
