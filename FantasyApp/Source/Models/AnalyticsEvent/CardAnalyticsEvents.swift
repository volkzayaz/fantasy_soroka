//
//  CardAnalyticsEvents.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 05.12.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

extension Analytics.Event {
    
    struct CardViewed: AnalyticsEvent {

        var name: String { return "Card Viewed" }

        enum NavigationContext: String {
            case Deck, RoomPlay, RoomMutual, ProfileMatched, MyFanasies, Blocked
        }

        let card: Fantasy.Card
        let context: NavigationContext
        let collapsedContent: Bool
        let spentTime: Int

        var props: [String : String]? {
            var x = [
                "Context": context.rawValue,
                "Name"   : card.text,
                "Category Type" : card.category,
                "Curated" : card.isPaid ? "true" : "false",
                "Time Spent" : "\(spentTime)"
            ]
            
            if !card.story.isEmpty {
                x["Content"] = "Story"
            }

            if collapsedContent {
                x["Content Opened"] = "Story"
            }
            
            return x
        }

    }
    
    struct CollectionViewed: AnalyticsEvent {
        
        var name: String { return "Collection Viewed" }

        enum NavigationContext: String {
            case Deck
        }

        let collection: Fantasy.Collection
        let context: NavigationContext
        let spentTime: Int
        
        var props: [String : String]? {
            return [
                "Context": context.rawValue,
                "Collection Name"   : collection.title,
                "Time Spent" : "\(spentTime)"
            ]
        }
        
    }
    
}
