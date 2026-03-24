//
//  Created by yugo.sugiyama on 2025/04/20
//  Copyright ©Sugiy All rights reserved.
//

import SwiftUI

public struct Pixel: Codable, Identifiable, Sendable {
    public var id: Int { index }
    public let index: Int
    public let r: Int
    public let g: Int
    public let b: Int

    public var color: Color {
        Color(red: Double(r) / 255.0,
              green: Double(g) / 255.0,
              blue: Double(b) / 255.0)
    }
}
