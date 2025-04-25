//
//  Created by yugo.sugiyama on 2025/04/20
//  Copyright ©Sugiy All rights reserved.
//

#if canImport(AppKit)
import AppKit

public typealias AppImage = NSImage
#elseif canImport(UIKit)
import UIKit

public typealias AppImage = UIImage
#endif
import SwiftUI

public extension AppImage {
    convenience init?(url: URL) {
        do {
            let data = try Data(contentsOf: url)
            self.init(data: data)
        } catch {
            return nil
        }
    }

    var asData: Data? {
#if os(iOS) || os(visionOS)
        return pngData()
#elseif os(macOS)
        guard let tiffRepresentation else { return nil }
        let bitmap = NSBitmapImageRep(data: tiffRepresentation)
        return bitmap?.representation(using: .png, properties: [:])
#endif
    }

    var asImage: Image {
#if os(iOS) || os(visionOS)
        return Image(uiImage: self)
#elseif os(macOS)
        return Image(nsImage: self)
#endif
    }

    var asCgImage: CGImage? {
#if os(macOS)
        // NSImage → CGImage 変換（サイズに注意）
        guard let tiffData = tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData) else {
            return nil
        }
        return bitmap.cgImage
#else
        return cgImage
#endif
    }
}

extension AppImage: @unchecked @retroactive Sendable {}

public extension Image {
    init?(data: Data) {
        guard let appImage = AppImage(data: data) else { return nil }
#if os(macOS)
        self.init(nsImage: appImage)
#else
        self.init(uiImage: appImage)
#endif
    }
}

