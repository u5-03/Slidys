//
//  Double+Angle.swift
//  HeadPosturePackage
//
//  Created by Yugo Sugiyama on 2025/01/02.
//

import Foundation

public extension Double {
    /// ラジアンから度数に変換
    var degrees: Double {
        self * 180 / .pi
    }

    /// 度数からラジアンに変換
    var radians: Double {
        self * .pi / 180
    }

    /// ラジアンから整数の度数に変換
    var degreesInt: Int {
        Int(degrees)
    }
}
