//
//  Color.swift
//  Slidys
//
//  Created by Yugo Sugiyama on 2024/10/27.
//

import SwiftUI

#if os(macOS)
import AppKit
typealias AppColor = NSColor
#elseif os(iOS) || os(visionOS) || os(tvOS)
import UIKit
typealias AppColor = UIColor
#endif

// Ref: https://zenn.dev/ueeek/articles/20240418color_filter_appstroage
extension Color: RawRepresentable {
    init(hex: String) {
       let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
       var int = UInt64()
       Scanner(string: hex).scanHexInt64(&int)
       let a, r, g, b: UInt64
       switch hex.count {
       case 3: // RGB (12-bit)
           (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
       case 6: // RGB (24-bit)
           (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
       case 8: // ARGB (32-bit)
           (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
       default:
           (a, r, g, b) = (255, 0, 0, 0)
       }

       self.init(
           .sRGB,
           red: Double(r) / 255,
           green: Double(g) / 255,
           blue: Double(b) / 255,
           opacity: Double(a) / 255
       )
   }

    public init?(rawValue: String) {
        guard let data = Data(base64Encoded: rawValue) else {
            self = .orange
            return
        }
        do {
            let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: AppColor.self, from: data) ?? .black
            self = Color(color)
        } catch {
            self = .orange
        }
    }

    public var rawValue: String {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: AppColor(self), requiringSecureCoding: false) as Data
            return data.base64EncodedString()
        } catch {
            return ""
        }
    }
}

