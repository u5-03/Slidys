import AppKit
import Foundation

// 使い方: swift make_rehearsal_pdf.swift <snapshotDir> <out.pdf>
// 各スライドの最終フェーズ画像の下に、スピーカーノート(フェーズ区切り付き)を載せた縦長ページの PDF を作る
let args = CommandLine.arguments
let dir = URL(fileURLWithPath: args[1])
let out = URL(fileURLWithPath: args[2])
let files = try FileManager.default.contentsOfDirectory(atPath: dir.path).filter { $0.hasSuffix(".png") }.sorted()
var lastPerSlide: [Int: String] = [:]
for f in files {
    guard let r = f.range(of: #"_slide(\d+)_"#, options: .regularExpression) else { continue }
    lastPerSlide[Int(f[r].filter { $0.isNumber })!] = f
}
let notes = try JSONSerialization.jsonObject(with: Data(contentsOf: dir.appendingPathComponent("notes.json"))) as! [[String: Any]]

let pageWidth: CGFloat = 1000
let margin: CGFloat = 40
let imageHeight = (pageWidth - margin * 2) * 1080 / 1920
let bodyFont = NSFont.systemFont(ofSize: 22)
let headFont = NSFont.boldSystemFont(ofSize: 20)
let sepColor = NSColor(calibratedRed: 0.95, green: 0.56, blue: 0.14, alpha: 1)

let data = NSMutableData()
let consumer = CGDataConsumer(data: data as CFMutableData)!
var box = CGRect(x: 0, y: 0, width: pageWidth, height: 1400)
let ctx = CGContext(consumer: consumer, mediaBox: &box, nil)!

for note in notes {
    let num = note["slide"] as! Int
    let segments = (note["segments"] as! [String]).filter { !$0.isEmpty }
    let text = NSMutableAttributedString()
    let para = NSMutableParagraphStyle(); para.lineSpacing = 6; para.paragraphSpacing = 10
    for (i, seg) in segments.enumerated() {
        if i > 0 {
            text.append(NSAttributedString(string: "▼ ここで次を表示\n", attributes: [.font: headFont, .foregroundColor: sepColor, .paragraphStyle: para]))
        }
        text.append(NSAttributedString(string: seg.trimmingCharacters(in: .whitespacesAndNewlines) + "\n", attributes: [.font: bodyFont, .foregroundColor: NSColor.black, .paragraphStyle: para]))
    }
    let textWidth = pageWidth - margin * 2
    let textHeight = ceil(text.boundingRect(with: CGSize(width: textWidth, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin]).height)
    let header: CGFloat = 50
    let pageHeight = margin + header + imageHeight + 24 + textHeight + margin
    var mb = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
    ctx.beginPage(mediaBox: &mb)
    let ns = NSGraphicsContext(cgContext: ctx, flipped: false)
    NSGraphicsContext.saveGraphicsState(); NSGraphicsContext.current = ns
    NSColor.white.setFill(); mb.fill()
    let title = "\(num) / \(notes.count)  \(note["name"] as! String)"
    title.draw(at: CGPoint(x: margin, y: pageHeight - margin - 28), withAttributes: [.font: NSFont.boldSystemFont(ofSize: 24), .foregroundColor: NSColor.darkGray])
    if let file = lastPerSlide[num], let img = NSImage(contentsOf: dir.appendingPathComponent(file)) {
        img.draw(in: CGRect(x: margin, y: pageHeight - margin - header - imageHeight, width: textWidth, height: imageHeight))
    }
    text.draw(with: CGRect(x: margin, y: margin, width: textWidth, height: textHeight), options: [.usesLineFragmentOrigin])
    NSGraphicsContext.restoreGraphicsState()
    ctx.endPage()
}
ctx.closePDF()
try (data as Data).write(to: out)
print("pages=\(notes.count) → \(out.path)")
