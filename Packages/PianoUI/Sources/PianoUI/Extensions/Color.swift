//
//  Color.swift
//
//
//  Created by Yugo Sugiyama on 2024/11/10.
//

import SwiftUI

#if os(macOS)
import AppKit
typealias AppColor = NSColor
#elseif os(iOS) || os(visionOS) || os(tvOS)
import UIKit
typealias AppColor = UIColor
#endif

extension Color: RawRepresentable {
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
