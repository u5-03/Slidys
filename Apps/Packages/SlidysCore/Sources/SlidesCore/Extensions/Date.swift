//
//  Date.swift
//  SlidysCore
//
//  Created by yugo.sugiyama on 2025/02/16.
//

import Foundation

public extension Date {
    init(year: Int, month: Int, day: Int) {
        let calendar = Calendar(identifier: .gregorian)
        self.init(
            timeIntervalSince1970: (calendar.date(from: DateComponents(year: year, month: month, day: day)) ?? .now).timeIntervalSince1970
        )
    }

    func offsetYears(offset: Int) -> Date? {
        return Calendar.current.date(byAdding: .year, value: offset, to: self)
    }

    func offsetMonths(offset: Int) -> Date? {
        return Calendar.current.date(byAdding: .month, value: offset, to: self)
    }

    func offsetDays(offset: Int) -> Date? {
        return Calendar.current.date(byAdding: .day, value: offset, to: self)
    }
}
