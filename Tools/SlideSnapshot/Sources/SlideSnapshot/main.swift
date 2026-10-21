//
//  main.swift
//  SlideSnapshot
//
//  指定デッキの全スライド(フェーズ込み)を 1920x1080 の PNG に書き出し、一覧 HTML も生成する。
//  引数: <deck> <outputDir> [language]   deck: iosdc2026 | flutterkaigi2026   language: ja(既定) | en
//

import AppKit
import Foundation
import ImageIO
import SlideKit
import SlidesCore
import SwiftUI
import UniformTypeIdentifiers
import iOSDC2026Slide
import FlutterKaigi2026Slide

private struct PDFExportRouter: FlutterKaigi2026Slide.RouterProtocol {
    func build(viewType: FlutterKaigi2026ViewType) -> AnyView {
        AnyView(EmptyView())
    }
}

@MainActor
func run() async throws {
    let args = CommandLine.arguments
    guard args.count >= 3 else {
        FileHandle.standardError.write("usage: SlideSnapshot <deck: iosdc2026|flutterkaigi2026> <outputDir>\n".data(using: .utf8)!)
        exit(2)
    }
    let deck = args[1]
    let outputDir = URL(fileURLWithPath: args[2])
    // 表示言語(多言語対応デッキ用)。コマンドラインツールにはアプリの言語設定が無いので、既定は日本語にする
    let language = args.count >= 4 ? (SlideLanguage(rawValue: args[3]) ?? .japanese) : .japanese
    SlideLanguageStore.shared.language = language
    try FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)

    // 一覧ビュー(SlideListView)を1枚のPNGに描画する検証モード
    if deck == "iosdc2026-list" {
        let listView = SlideGridView(
            slideIndexController: iOSDC2026SlideView.makeSlideIndexController(),
            listTextStyle: iOSDC2026SlideView.listTextStyle,
            columns: 4,
            tileWidth: 440
        )
        let renderer = ImageRenderer(content: listView)
        renderer.scale = 1
        guard let cgImage = renderer.cgImage else {
            FileHandle.standardError.write("list render failed\n".data(using: .utf8)!)
            exit(1)
        }
        let url = outputDir.appendingPathComponent("list_overview.png")
        if let dest = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) {
            CGImageDestinationAddImage(dest, cgImage, nil)
            CGImageDestinationFinalize(dest)
        }
        print("wrote \(url.path)")
        exit(0)
    }

    let controller: SlideIndexController
    let listTextStyle: ListTextStyle
    switch deck {
    case "iosdc2026":
        controller = iOSDC2026SlideView.makeSlideIndexController()
        listTextStyle = iOSDC2026SlideView.listTextStyle
    case "flutterkaigi2026", "flutterkaigi2026-pdf":
        // Flutter のデモ画面は DefaultRouter(EmptyView)になるので、スマホ枠だけが描画される
        controller = FlutterKaigi2026SlideView.makeSlideIndexController()
        listTextStyle = FlutterKaigi2026SlideView.listTextStyle
    default:
        FileHandle.standardError.write("unknown deck: \(deck)\n".data(using: .utf8)!)
        exit(2)
    }

    if deck == "flutterkaigi2026-pdf" {
        // アプリの「PDFを書き出す」と同じ公開APIを使う。
        guard let source = FlutterKaigi2026SlideView(router: PDFExportRouter()).pdfExportSource else {
            throw CocoaError(.fileReadUnknown)
        }
        let exportedURL = try await SlidePDFExporter.export(source)
        let destination = outputDir.appendingPathComponent(exportedURL.lastPathComponent)
        if FileManager.default.fileExists(atPath: destination.path) {
            try FileManager.default.removeItem(at: destination)
        }
        try FileManager.default.copyItem(at: exportedURL, to: destination)
        print("exported \(source.slides.count) pages with SlidePDFExporter: \(destination.path)")
        return
    }

    let size = SlideSize.standard16_9
    let theme = CustomSlideTheme(showSlideIndex: true, listTextStyle: listTextStyle)
    let view = SlideRouterView(slideIndexController: controller)
        .slideTheme(theme)
        .foregroundColor(.black)
        .background(.white)
        .frame(width: size.width, height: size.height)

    var written: [(index: Int, slide: Int, file: String, name: String)] = []
    controller.backToFirst()
    var shot = 0
    repeat {
        let renderer = ImageRenderer(content: view)
        renderer.scale = 1
        guard let cgImage = renderer.cgImage else {
            FileHandle.standardError.write("render failed at \(shot)\n".data(using: .utf8)!)
            continue
        }
        let slideNumber = controller.currentIndex + 1
        let typeName = String(describing: type(of: controller.currentSlide))
        let file = String(format: "%03d_slide%02d_%@.png", shot + 1, slideNumber, typeName)
        let url = outputDir.appendingPathComponent(file)
        guard let dest = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else { continue }
        CGImageDestinationAddImage(dest, cgImage, nil)
        CGImageDestinationFinalize(dest)
        written.append((shot + 1, slideNumber, file, typeName))
        shot += 1
    } while controller.forward()

    // 一覧 HTML
    var html = """
    <!doctype html><html lang="ja"><head><meta charset="utf-8"><title>Slide snapshots: \(deck)</title>
    <style>
      body{font-family:-apple-system,sans-serif;background:#1e1f26;color:#ddd;margin:0;padding:24px}
      h1{font-size:20px;margin:0 0 16px}
      .grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(420px,1fr));gap:20px}
      figure{margin:0;background:#2a2b35;border-radius:10px;padding:10px}
      img{width:100%;border-radius:6px;display:block;background:#000}
      figcaption{font-size:13px;margin-top:8px;color:#bbb;word-break:break-all}
      a{color:#8fbfff}
    </style></head><body>
    <h1>\(deck) — \(written.count) shots (\(controller.slides.count) slides, フェーズ込み)</h1>
    <div class="grid">
    """
    for w in written {
        html += "<figure><a href=\"\(w.file)\" target=\"_blank\"><img src=\"\(w.file)\" loading=\"lazy\"></a><figcaption>#\(w.index) — slide \(w.slide) / \(controller.slides.count): \(w.name)</figcaption></figure>\n"
    }
    html += "</div></body></html>"
    try html.write(to: outputDir.appendingPathComponent("index.html"), atomically: true, encoding: .utf8)

    // スピーカーノート(リハーサル用 PDF の生成に使う)
    var notes: [[String: Any]] = []
    for (i, slide) in controller.slides.enumerated() {
        let segments = (slide as? any PhasedScriptProviding)?.scriptSegments ?? [slide.script]
        notes.append([
            "slide": i + 1,
            "name": String(describing: type(of: slide)),
            "segments": segments,
        ])
    }
    let json = try JSONSerialization.data(withJSONObject: notes, options: [.prettyPrinted])
    try json.write(to: outputDir.appendingPathComponent("notes.json"))
    print("wrote \(written.count) shots to \(outputDir.path)")
}

// ImageRenderer は AppKit 環境で動かす(NSApplication を初期化しておく)
_ = NSApplication.shared
NSApp.setActivationPolicy(.prohibited)
Task { @MainActor in
    do {
        try await run()
        exit(0)
    } catch {
        FileHandle.standardError.write("error: \(error)\n".data(using: .utf8)!)
        exit(1)
    }
}
// PDF の非同期描画でも AppKit の処理をメインスレッドで進める。
NSApp.run()
