//
//  Array.swift
//  SlidysCore
//
//  Created by yugo.sugiyama on 2025/02/20.
//

import Foundation

public extension Array {
    var randomSubset: [Element] {
        let randomCount = Int.random(in: 0...self.count)
        return Array(self.shuffled().prefix(randomCount))
    }
}
