//
//  AnalyticsEventRoom.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 05.12.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

extension Analytics.Event {
    
    struct RoomAccepted {
        
        enum Source: String {
            case Profile, Room
        }
        
    }

    struct DraftRoomCreated: AnalyticsEvent {
        
        var name: String { return "Room Draft Created" }
        var props: [String : String]? {
            return [
                "User ID": User.current?.id ?? "Unknown"
            ]
        }
        
    }
    
    struct DraftRoomShared: AnalyticsEvent {
           
        enum Of: String {
            case share = "Share"
            case add = "Add"
        }; let type: Of
        
        var name: String { return "Room Draft Shared" }
        var props: [String : String]? {
            return [
                "User ID": User.current?.id ?? "Unknown",
                "Type" : type.rawValue
            ]
        }
           
    }
    
}
