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
        dateFormatter.dateFormat = "MMMM dd yyyy" // "Monday, Mar 7 2016"
        return dateFormatter
    }()

    func toWeekDayAndDateString() -> String {
        return Date.weekdayAndDateStampDateFormatter.string(from: self)
    }

    func compare(with date: Date, by component: Calendar.Component) -> Int {
        let days1 = Calendar.current.component(component, from: self)
        let days2 = Calendar.current.component(component, from: date)
        return days1 - days2
    }
}
