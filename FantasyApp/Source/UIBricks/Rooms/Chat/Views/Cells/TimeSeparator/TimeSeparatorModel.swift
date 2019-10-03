//
//  TimeSeparatorModel.swift
//  FantasyApp
//
//  Created by Admin on 30.09.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import UIKit
import Chatto

class TimeSeparatorModel: ChatItemProtocol {
    let uid: String
    let type: String = TimeSeparatorModel.chatItemType
    let date: String

    static var chatItemType: ChatItemType {
        return Chat.CellType.timeSeparator.rawValue
    }

    init(uid: String, date: String) {
        self.date = date
        self.uid = uid
    }
}


// MARK: - Date formatting
extension Date {
    private static let weekdayAndDateStampDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.dateFormat = "MMMM dd yyyy"
        return dateFormatter
    }()

    func toWeekDayAndDateString() -> String {
        let formatter = Date.weekdayAndDateStampDateFormatter
        let formatWithYear = "MMMM dd yyyy"
        let formatWithoutYear = "MMMM dd"
        formatter.dateFormat = distance(from: Date(), in: .day) > 365 ? formatWithYear : formatWithoutYear
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
