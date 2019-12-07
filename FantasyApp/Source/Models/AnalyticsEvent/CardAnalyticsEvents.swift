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

        let card: Fantasy.Card
        let context: Fantasy.Card.NavigationContext
        let collapsedContent: Bool
        let spentTime: Int

        var props: [String : String]? {
            var x = [
                "Context": context.rawValue,
                "Name"   : card.text,
                "Category Type" : card.category,
                "Curated" : card.isPaid ? "true" : "false",
                "Art"     : card.art,
                "Collection Name" : card.collectionName,
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

        enum NavigationContext {
            case Collection
            case Card(Fantasy.Card.NavigationContext)
            
            var rawValue: String {
                switch self {
                case .Collection: return "Collection"
                case .Card(let context): return context.rawValue
                }
            }
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

extension Fantasy.Card {
    
    ///which screen was before action happened
    enum NavigationContext: String {
        case Deck, RoomPlay, RoomMutual, ProfileMatched, MyFanasies, MyFantasiesBlocked
    }
    
    ///on which screen action happend
    enum ActionContext {
        
        case Deck
        case RoomDeck
        
        case inside(NavigationContext)
        
        var stakeholdersParams: [String: String] {
            
            let context: String
            let representation: String
            
            switch self {
            case .Deck:
                context = "Deck"
                representation = "Preview"
                
            case .RoomDeck:
                context = "RoomPlay"
                representation = "Preview"
                
            case .inside(let navigationContext):
                context = navigationContext.rawValue
                representation = "Expanded"
            }
            
            return ["context": context, "representation": representation]
        }
        
    }
 
}
