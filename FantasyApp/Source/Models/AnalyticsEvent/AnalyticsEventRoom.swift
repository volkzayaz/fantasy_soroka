//
//  AnalyticsEventRoom.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 05.12.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

extension Analytics.Event {
    
    struct RoomAccepted: AnalyticsEvent {
        
        enum Source: String {
            case Profile, Room
        }
        
        var name: String { return "Room Accepted" }
        
        let isFrozen: Bool
        
        var props: [String : String]? {
            return ["Frozen": isFrozen ? "true" : "false"]
        }
        
    }
    
}
