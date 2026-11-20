import Foundation
import CoreGraphics

/// Pure geometry for ScreenCaptureKit surfaces. All crops are applied AFTER EXIF orientation.
struct PresenterStreamLayout {
    let crop: CGRect // top-left pixel coordinates in the oriented buffer
    let orientedSize: CGSize

    static func make(buffer: CGSize, contentPixels: CGRect, orientation: Int,
                     capturedWindow: CGSize, sourceWindow: CGRect, slide: CGRect) -> Self? {
        guard (1...8).contains(orientation), buffer.width > 0, buffer.height > 0,
              contentPixels.width > 0, contentPixels.height > 0,
              CGRect(origin: .zero, size: buffer).insetBy(dx: -1, dy: -1).contains(contentPixels),
              sourceWindow.width > 0, sourceWindow.height > 0,
              sourceWindow.insetBy(dx: -1, dy: -1).contains(slide), slide.width > 1, slide.height > 1 else { return nil }
        // Size is a necessary, not sufficient, source identity check on iOS.
        func close(_ a: CGFloat, _ b: CGFloat) -> Bool { abs(a - b) <= max(3, b * 0.02) }
        let swapsAxes = orientation >= 5
        let directlyMatches = close(capturedWindow.width, sourceWindow.width) && close(capturedWindow.height, sourceWindow.height)
        let rotatedMatches = swapsAxes && close(capturedWindow.height, sourceWindow.width) && close(capturedWindow.width, sourceWindow.height)
        guard directlyMatches || rotatedMatches else { return nil }
        let orientedSize = swapsAxes ? CGSize(width: buffer.height, height: buffer.width) : buffer
        func orient(_ point: CGPoint) -> CGPoint {
            let x = point.x / buffer.width, y = point.y / buffer.height
            let value: CGPoint
            switch orientation {
            case 2: value = CGPoint(x: 1-x, y: y)
            case 3: value = CGPoint(x: 1-x, y: 1-y)
            case 4: value = CGPoint(x: x, y: 1-y)
            case 5: value = CGPoint(x: y, y: x)
            case 6: value = CGPoint(x: 1-y, y: x)
            case 7: value = CGPoint(x: 1-y, y: 1-x)
            case 8: value = CGPoint(x: y, y: 1-x)
            default: value = CGPoint(x: x, y: y)
            }
            return CGPoint(x: value.x * orientedSize.width, y: value.y * orientedSize.height)
        }
        let first = orient(CGPoint(x: contentPixels.minX, y: contentPixels.minY))
        let opposite = orient(CGPoint(x: contentPixels.maxX, y: contentPixels.maxY))
        let content = CGRect(x: min(first.x, opposite.x), y: min(first.y, opposite.y),
                             width: abs(opposite.x-first.x), height: abs(opposite.y-first.y))
        let crop = CGRect(x: content.minX + (slide.minX-sourceWindow.minX) / sourceWindow.width * content.width,
                          y: content.minY + (slide.minY-sourceWindow.minY) / sourceWindow.height * content.height,
                          width: slide.width / sourceWindow.width * content.width,
                          height: slide.height / sourceWindow.height * content.height)
        return Self(crop: crop, orientedSize: orientedSize)
    }
}
