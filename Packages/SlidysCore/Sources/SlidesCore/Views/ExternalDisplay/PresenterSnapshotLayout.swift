import Foundation
import CoreGraphics

struct PresenterSnapshotLayout {
    let viewport: CGRect
    let screenFrame: CGRect

    static func make(source: CGRect, screen: CGRect, output: CGRect) -> Self? {
        guard source.width > 1, source.height > 1, screen.contains(source),
              output.width > 0, output.height > 0 else { return nil }
        let scale = min(output.width / source.width, output.height / source.height)
        let size = CGSize(width: source.width * scale, height: source.height * scale)
        return Self(
            viewport: CGRect(x: output.midX - size.width / 2, y: output.midY - size.height / 2,
                             width: size.width, height: size.height),
            screenFrame: CGRect(x: -(source.minX - screen.minX) * scale,
                                y: -(source.minY - screen.minY) * scale,
                                width: screen.width * scale, height: screen.height * scale)
        )
    }
}

/// One shared bitmap sized for the most demanding destination, bounded to Full HD.
struct PresenterCaptureResolution {
    static func pixels(source: CGSize, destinations: [CGSize]) -> CGSize? {
        guard source.width.isFinite, source.height.isFinite,
              source.width > 1, source.height > 1 else { return nil }
        let requiredScale = destinations.compactMap { destination -> CGFloat? in
            guard destination.width.isFinite, destination.height.isFinite,
                  destination.width > 0, destination.height > 0 else { return nil }
            return min(destination.width / source.width, destination.height / source.height)
        }.max() ?? 1
        let edgeScale = 1920 / max(source.width, source.height)
        let areaScale = sqrt((1920 * 1080) / (source.width * source.height))
        let scale = min(requiredScale, edgeScale, areaScale)
        return CGSize(width: max(1, floor(source.width * scale)),
                      height: max(1, floor(source.height * scale)))
    }
}

/// Leave CPU headroom for input and the source view; match divisors of display refresh.
struct PresenterCapturePacing {
    /// Spend at most roughly 20% of the main thread on the optional outer copy.
    /// This is a post-capture quiet period, not a requested display refresh rate.
    static func outerQuietPeriod(captureMS: Double) -> TimeInterval {
        guard captureMS.isFinite, captureMS > 0 else { return 0.5 }
        return max(0.5, captureMS / 1000 * 4)
    }

    static func target(sourceMaximum: Int, outputMaximum: Int, captureMS: Double) -> Float {
        let ceiling = max(1, min(sourceMaximum, outputMaximum))
        guard captureMS.isFinite, captureMS > 0 else { return Float(min(30, ceiling)) }
        let budgetRate = 1000 / (captureMS * 1.5)
        let rates = (1...8).map { Double(ceiling) / Double($0) }.filter { $0 >= 15 }
        return Float(rates.first(where: { $0 <= budgetRate }) ?? Double(min(15, ceiling)))
    }
}
