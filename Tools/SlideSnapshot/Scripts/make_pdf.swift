import AppKit
import PDFKit

// 使い方: swift make_pdf.swift <snapshotDir> <out.pdf>
// スナップショット(NNN_slideMM_Name.png)を、スライド番号ごとに最後の1枚(全フェーズ表示後)だけ集めて PDF にする
let args = CommandLine.arguments
let dir = URL(fileURLWithPath: args[1])
let out = URL(fileURLWithPath: args[2])
let files = try FileManager.default.contentsOfDirectory(atPath: dir.path)
    .filter { $0.hasSuffix(".png") }
    .sorted()
var lastPerSlide: [Int: String] = [:]
var order: [Int] = []
for f in files {
    // 012_slide12_IOSFeedbackOverviewSlide.png → slide 12
    guard let range = f.range(of: #"_slide(\d+)_"#, options: .regularExpression) else { continue }
    let num = Int(f[range].filter { $0.isNumber })!
    if lastPerSlide[num] == nil { order.append(num) }
    lastPerSlide[num] = f
}
let pdf = PDFDocument()
for (i, num) in order.enumerated() {
    let url = dir.appendingPathComponent(lastPerSlide[num]!)
    guard let image = NSImage(contentsOf: url), let page = PDFPage(image: image) else { continue }
    pdf.insert(page, at: i)
}
guard pdf.write(to: out) else { fatalError("write failed") }
print("pages=\(pdf.pageCount) → \(out.path)")
