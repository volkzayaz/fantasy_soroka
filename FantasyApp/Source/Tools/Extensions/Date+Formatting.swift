//
//  Date+Formatting.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 09.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

extension Date {

    // MARK: - Formatters
    private static let componentsFormatter = DateComponentsFormatter()

    private static let hoursAndMinutesDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.dateFormat = "HH:MM"
        return dateFormatter
    }()

    private static let weekdayAndDateStampDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.dateFormat = "MMMM dd yyyy"
        return dateFormatter
    }()

    // MARK: - Conversions
    func toMessageTimestampString() -> String {
        return Date.hoursAndMinutesDateFormatter.string(from: self)
    }

    func toWeekDayAndDateString() -> String {
        let formatter = Date.weekdayAndDateStampDateFormatter
        let formatWithYear = "MMMM dd yyyy"
        let formatWithoutYear = "MMMM dd"
        formatter.dateFormat = distance(from: Date(), in: .day) > 365 ? formatWithYear : formatWithoutYear
        return formatter.string(from: self)
    }

    func toTimeAgoString() -> String {
        let formatter = Date.componentsFormatter
        formatter.unitsStyle = .short
        formatter.maximumUnitCount = 1
        formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]
        let timeString = formatter.string(from: self, to: Date())

        return timeString != nil ? R.string.localizable.generalAgo(timeString!) :
            R.string.localizable.generalJustNow()
    }

    func distance(from date: Date, in component: Calendar.Component) -> Int {
        return Calendar.current.dateComponents([component], from: self, to: date).value(for: component) ?? 0
    }

    func compare(with date: Date, by component: Calendar.Component) -> Int {
        let days1 = Calendar.current.component(component, from: self)
        let days2 = Calendar.current.component(component, from: date)
        return days1 - days2
    }
}

