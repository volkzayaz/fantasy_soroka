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
        let itemName: String?
        let discount: String?
        
        init(context: SubscriptionViewModel.Page, itemName: String? = nil, discount: String? = nil) {
            self.context = context
            self.itemName = itemName
            self.discount = discount
        }
        
        var name: String { return "Purchase Interest" }
        
        var props: [String : String]? {
            var params = [String: String]()
            
            var ctx = ""
            switch context {
            case .fantasyX3: ctx = "DeckLimit"
            case .member: ctx = "ProfileMembership"
            //case .screenProtect: ctx = "RoomScreenProtect"
            case .teleport: ctx = "SearchActiveCity"
            case .unlimRooms: ctx = "RoomFrozenLimit"
            case .subscriptionOffer: ctx = "SubscriptionOffer"
            }
            
            params["Context"] = ctx
            
            if let itemName = itemName {
                params["Item Name"] = itemName
            }
            
            if let discount = discount {
                params["Item Discount"] = discount
            }
            
            return params
        }
    }
    
}

extension Analytics.Event {
    
    struct PurchaseCollectionInterest: AnalyticsEvent {
        
        enum Context {
            case collection, promo
            
            var name: String {
                switch self {
                case .collection: return "Collection Page"
                case .promo: return "Promo Page"
                }
            }
        }
        
        let context: Context
        let collectionName: String
        let isPriceVisable: Bool
        
        var name: String { return "Purchase Collection Interest" }
        
        var props: [String : String]? {
            [
                "Collection Interest Context": context.name,
                "Collection Price Visibility": String(isPriceVisable),
                "Name": collectionName
            ]
        }
    }
}
