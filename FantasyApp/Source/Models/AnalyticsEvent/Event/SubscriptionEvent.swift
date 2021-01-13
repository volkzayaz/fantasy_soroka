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
        
        enum Context: String {
            case x3NewProfilesDaily = "SearchLimit"
            case globalMode = "SearchGlobalMode"
            case changeActiveCity = "SearchActiveCity"
            case accessToAllDecks = "AccessToAllDecks"
            case x3NewCardsDaily = "DeckLimit"
            case unlimitedRooms = "RoomFrozenLimit"
            case memberBadge = "ProfileMembership"
            case subscriptionOffer = "SubscriptionOffer"
        }
        
        enum PurchaseType: String {
            case regular = "Regular"
        }
        
        enum PaymentStatus: String {
            case success = "Success"
            case failed = "Failed"
            case cancel = "Cancel"
            case resignActive = "Resign Active"
            case terminate = "Terminate"
        }
        
        let context: Context
        let content: String?
        let type: PurchaseType?
        let paymentStatus: PaymentStatus?
        let spentTime: Int?
        let itemName: String?
        let discount: String?
        
        init(context: Context, content: String? = nil, type: PurchaseType? = nil, paymentStatus: PaymentStatus? = nil, spentTime: Int? = nil, itemName: String? = nil, discount: String? = nil) {
            self.context = context
            self.content = content
            self.type = type
            self.paymentStatus = paymentStatus
            self.spentTime = spentTime
            self.itemName = itemName
            self.discount = discount
        }
        
        var name: String { return "Purchase Interest" }
        
        var props: [String : String]? {
            var params = [String: String]()
            params["Context"] = context.rawValue
            params["Content"] = content
            
            if let type = type {
                params["Type"] = type.rawValue
            }
            
            if let paymentStatus = paymentStatus {
                params["Payment Status"] = paymentStatus.rawValue
            }
            
            if let spentTime = spentTime {
                params["Time Spent"] = "\(spentTime)"
            }
            
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
                case .collection: return "ComeBackSpecialOffer"
                case .promo: return "PriceVisibilityPromoOffer"
                }
            }
        }
        
        let context: Context
        let collectionName: String
        let isPriceVisable: Bool
        let discount: String?
        
        init(context: Context, collectionName: String, isPriceVisable: Bool, discount: String? = nil) {
            self.context = context
            self.collectionName = collectionName
            self.isPriceVisable = isPriceVisable
            self.discount = discount
        }
        
        var name: String { return "Purchase Collection Interest" }
        
        var props: [String : String]? {
            var params = [
                "Collection Interest Context": context.name,
                "Collection Price Visibility": String(isPriceVisable),
                "Name": collectionName
            ]
            
            if let discount = discount {
                params["Discount"] = discount
            }
            
            return params
        }
    }
}
