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
    
    let newMatch: Bool = true
    let newMessage: Bool = true
    let newFantasyMatch: Bool = true
    
    
}
