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
            var x = card.analyticsProps
            x["Context"] = context.rawValue
            x["Time Spent"] = "\(spentTime)"
            
            if !card.story.isEmpty {
                x["Content"] = "Story"
            }

            if collapsedContent {
                x["Content Opened"] = "Story"
            }
            
            return x
        }

    }

    struct CardOpenTime: AnalyticsEvent {

        var name: String { return "Card Time Open" }

        let card: Fantasy.Card
        let context: Fantasy.Card.NavigationContext
        let spentTime: Int

        var props: [String : String]? {
            var x = card.analyticsProps
            x["Context"] = context.rawValue
            x["Time till Opened"] = "\(spentTime)"
            
            return x
        }

    }
    
    struct CardReactionTime: AnalyticsEvent {

        var name: String { return "Card Time Reaction" }

        let card: Fantasy.Card
        let context: Fantasy.Card.NavigationContext
        let spentTime: Int
        let reaction: Fantasy.Card.Reaction

        var props: [String : String]? {
            var x = card.analyticsProps
            x["Context"] = context.rawValue
            x["Time till Reaction"] = "\(spentTime)"
            if reaction == .like {
                x["Reaction"] = "Like"
            }
            else if reaction == .dislike {
                x["Reaction"] = "Dislike"
            }
            else if reaction == .block {
                x["Reaction"] = "Block"
            }
            
            return x
        }
    }
    
    struct CardShared: AnalyticsEvent {

        var name: String { return "Card Shared" }

        let card: Fantasy.Card
        let context: Fantasy.Card.NavigationContext

        var props: [String : String]? {
            var x = card.analyticsProps
            x["Context"] = context.rawValue
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
        case Deck, DeckDetails, RoomPlay, RoomMutual, ProfileMatched, MyFantasies, MyFantasiesBlocked, ShareLink, CollectionDetails
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
 
    var analyticsProps: [String: String] {
        var x = [
            "Card Id" : id,
            "Collection Name" : collectionName,
            "Category Type" : category,
            "Name"   : text,
            "Curated" : isPaid ? "true" : "false",
            "Art"     : art,
        ]
        
        if !story.isEmpty {
            x["Content"] = "Story"
        }
        
        return x
    }
    
}
