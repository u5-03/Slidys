//
//  Date+Formatting.swift
//  SlidysCore
//
//  Created by yugo.sugiyama on 2025/02/18.
//

import Foundation

/// String->Date変換用のフォーマット
public enum StringToDateFormat: String {
    case dateFormat = "yyyy-MM-dd"
    case dateTimeFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
}

/// Date->String変換用のフォーマット
public enum DateToStringFormat: String {

    case display = "yyyy/MM.dd(EEE)"
    case dateTimeWithWeekDay = "yyyy/MM/dd(EEEEE) HH:mm"
    case dateTimeWithWeekDayNoZero = "yyyy/M/d(EEEEE) H:mm"
    case dateWithWeekDayNoZero = "yyyy/M/d(EEEEE)"
    case dateWithWeekDay = "yyyy/MM/dd(EEEEE)"
    case time = "HH:mm"
    case timeHourNoZero = "H:mm"
    case day = "d"
    case weekDay = "eee"
    case monthDay = "MM/dd"
    case dateWithTime = "yyyy/MM/dd HH:mm"
    case dateWithTimeNoZero = "yyyy/M/d H:mm"
    case monthDayWithTime = "M/d HH:mm"
    case yearNoZeroMonthDay = "yyyy/M/d"
    case yearMonth = "yyyy/MM"
    case yearMonthDay = "yyyy/MM/dd"
    case dateTimeFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    case dateFormat = "yyyy-MM-dd"
    case defaultPictureName = "MM月-dd-yyyy-HH:mm:ss-'JST'-+0900"
    case dateWithTimeInJa = "yyyy年MM月dd日 H:mm"
    case dateTimeFormatForPath = "yyyy-MM-dd_HH-mm-ss-SSS"
    case allIntFormat = "yyyyMMddHHmmss"
}

extension DateFormatter {
    /// String->DateとDate->String変換のためのDateFormatter
    ///
    /// DateFormatterの生成が遅いため、1つのインスタンスを使い回す
    fileprivate static let shared: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = .current
        return formatter
    }()
}

extension String {
    /// String->Date変換を行う
    ///
    /// - parameter format: 変換のフォーマット
    /// - returns: 変換されたDate、もしくは変換に失敗した場合、nil
    public func asDate(withFormat format: StringToDateFormat) -> Date? {
        DateFormatter.shared.dateFormat = format.rawValue
        return DateFormatter.shared.date(from: self)
    }
}

extension Date {
    /// Date->String変換を行う
    ///
    /// - parameter format: 変換のフォーマット
    /// - returns: 変換されたString
    public func asString(withFormat format: DateToStringFormat) -> String {
        DateFormatter.shared.dateFormat = format.rawValue
        return DateFormatter.shared.string(from: self)
    }
}
