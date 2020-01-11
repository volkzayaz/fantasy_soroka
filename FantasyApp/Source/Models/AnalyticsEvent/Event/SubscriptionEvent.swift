//
//  SubscriptionEvent.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 11.01.2020.
//  Copyright © 2020 Fantasy App. All rights reserved.
//

import Foundation

extension Analytics.Event {
    
    struct PurchaseInterest: AnalyticsEvent {
        
        let context: SubscriptionViewModel.Page

        var name: String { return "Purchase Interest" }
        
        var props: [String : String]? {
            
            var ctx = ""
            switch context {
            case .fantasyX3: ctx = "DeckLimit"
            case .member: ctx = "ProfileMembership"
            case .screenProtect: ctx = "RoomScreenProtect"
            case .teleport: ctx = "SearchActiveCity"
            case .unlimRooms: ctx = "RoomFrozenLimit"
            }
            
            return ["Context":  ctx]
        }
    }
    
}
