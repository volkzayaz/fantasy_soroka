//
//  NotificationSettings.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 10/9/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

struct NotificationSettings: Codable, Equatable, ParsePresentable {
    
    static var className: String {
        return "NotificationSettings"
    }

    var objectId: String?
    
    ///these names are actually keys on Parse Table,
    ///so be accurate when chaning them
    var newMatch: Bool = true
    var newMessage: Bool = true
    var newFantasyMatch: Bool = true
    
    
}

struct RoomNotificationSettings: Codable, Equatable, ParsePresentable {

    static var className: String {
        return "RoomNotificationSettings"
    }

    var objectId: String?

    ///these names are actually keys on Parse Table,
    ///so be accurate when chaning them
    var roomId: String!
    var newMessage: Bool = true
    var newFantasyMatch: Bool = true


}

