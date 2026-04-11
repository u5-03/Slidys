#!/usr/bin/env swift
// Overlays promotional text (headline + subheadline) on a PNG image.
// Usage: overlay_text <input_png> <output_png> <headline> <subheadline>

import AppKit
import CoreText

guard CommandLine.arguments.count >= 5 else {
    fputs("Usage: overlay_text <input_png> <output_png> <headline> <subheadline>\n", stderr)
    exit(1)
}

let inputPath = CommandLine.arguments[1]
let outputPath = CommandLine.arguments[2]
let headline = CommandLine.arguments[3]
let subheadline = CommandLine.arguments[4]

// Load input image
guard let imageData = try? Data(contentsOf: URL(fileURLWithPath: inputPath)),
      let imageSource = CGImageSourceCreateWithData(imageData as CFData, nil),
      let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
    fputs("Error: Failed to load image from \(inputPath)\n", stderr)
    exit(1)
}

let width = cgImage.width
let height = cgImage.height

// Create drawing context
guard let colorSpace = cgImage.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB),
      let context = CGContext(
          data: nil,
          width: width,
          height: height,
          bitsPerComponent: 8,
          bytesPerRow: 0,
          space: colorSpace,
          bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
      ) else {
    fputs("Error: Failed to create graphics context\n", stderr)
    exit(1)
}

// Draw original image
context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

// Configure text attributes
let scale: CGFloat = CGFloat(width) / 2732.0 // Normalize to visionOS simulator width
let headlineFontSize: CGFloat = 72.0 * scale
let subheadlineFontSize: CGFloat = 44.0 * scale

let headlineFont = CTFontCreateWithName("SFProRounded-Bold" as CFString, headlineFontSize, nil)
let subheadlineFont = CTFontCreateWithName("SFProRounded-Medium" as CFString, subheadlineFontSize, nil)

// Fallback to system font if SF Pro Rounded is not available
let actualHeadlineFont: CTFont = {
    let name = CTFontCopyPostScriptName(headlineFont) as String
    if name.contains("SFPro") || name.contains("Rounded") {
        return headlineFont
    }
    return CTFontCreateWithName(".AppleSystemUIFontRounded-Bold" as CFString, headlineFontSize, nil)
}()

let actualSubheadlineFont: CTFont = {
    let name = CTFontCopyPostScriptName(subheadlineFont) as String
    if name.contains("SFPro") || name.contains("Rounded") {
        return subheadlineFont
    }
    return CTFontCreateWithName(".AppleSystemUIFontRounded-Medium" as CFString, subheadlineFontSize, nil)
}()

let white = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
let shadowColor = CGColor(red: 0, green: 0, blue: 0, alpha: 0.6)

let headlineAttributes: [NSAttributedString.Key: Any] = [
    .font: actualHeadlineFont,
    .foregroundColor: white,
]

let subheadlineAttributes: [NSAttributedString.Key: Any] = [
    .font: actualSubheadlineFont,
    .foregroundColor: white,
]

// Calculate text sizes
let headlineStr = NSAttributedString(string: headline, attributes: headlineAttributes)
let subheadlineStr = NSAttributedString(string: subheadline, attributes: subheadlineAttributes)

let headlineLine = CTLineCreateWithAttributedString(headlineStr)
let subheadlineLine = CTLineCreateWithAttributedString(subheadlineStr)

let headlineBounds = CTLineGetBoundsWithOptions(headlineLine, .useGlyphPathBounds)
let subheadlineBounds = CTLineGetBoundsWithOptions(subheadlineLine, .useGlyphPathBounds)

// Position text above the window (about 10% from top of image)
// visionOS simulator: 2732x2048, window ~1400x900 centered → top of window at ~28%
// Text at 10% leaves clear gap between text and window
let lineSpacing: CGFloat = 12.0 * scale
let totalTextHeight = headlineBounds.height + lineSpacing + subheadlineBounds.height
let topMargin = CGFloat(height) * 0.15

// CGContext has flipped Y (origin at bottom-left)
let headlineY = CGFloat(height) - topMargin - headlineBounds.height
let subheadlineY = headlineY - lineSpacing - subheadlineBounds.height

let headlineX = (CGFloat(width) - headlineBounds.width) / 2.0
let subheadlineX = (CGFloat(width) - subheadlineBounds.width) / 2.0

// Draw shadow
context.saveGState()
context.setShadow(offset: CGSize(width: 0, height: -2 * scale), blur: 8 * scale, color: shadowColor)

// Draw headline
context.textPosition = CGPoint(x: headlineX, y: headlineY)
CTLineDraw(headlineLine, context)

// Draw subheadline
context.textPosition = CGPoint(x: subheadlineX, y: subheadlineY)
CTLineDraw(subheadlineLine, context)

context.restoreGState()

// Save result
guard let resultImage = context.makeImage() else {
    fputs("Error: Failed to create result image\n", stderr)
    exit(1)
}

let rep = NSBitmapImageRep(cgImage: resultImage)
guard let pngData = rep.representation(using: .png, properties: [:]) else {
    fputs("Error: Failed to create PNG data\n", stderr)
    exit(1)
}

do {
    try pngData.write(to: URL(fileURLWithPath: outputPath))
} catch {
    fputs("Error: Failed to write output: \(error.localizedDescription)\n", stderr)
    exit(1)
}
