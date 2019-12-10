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
    private static let timeAgoComponentsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .short
        formatter.maximumUnitCount = 1
        formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]

        return formatter
    }()

    private static let timeLeftComponentsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = [.pad]

        return formatter
    }()

    private static let hoursAndMinutesDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        //dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter
    }()

    private static let weekdayAndDateStampDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.dateFormat = "MMMM dd yyyy"
        return dateFormatter
    }()
    
    private static let analyticsTimeFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.dateFormat = "yyyy-MM-dd"
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
        let formatter = Date.timeAgoComponentsFormatter
        let timeString = formatter.string(from: self, to: Date())
        
        return timeString != nil ? R.string.localizable.generalAgo(timeString!) :
            R.string.localizable.generalJustNow()
    }

    func toTimeLeftString() -> String {
        let formatter = Date.timeLeftComponentsFormatter

        return formatter.string(from: timeIntervalSinceNow) ?? ""
    }
    
    func toAnalyticsTime() -> String {
        let formatter = Date.analyticsTimeFormatter

        return formatter.string(from: self)
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

