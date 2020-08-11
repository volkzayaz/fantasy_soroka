//
//  CollectionOffer.swift
//  FantasyApp
//
//  Created by Vodolazkyi Anton on 21.07.2020.
//  Copyright © 2020 Fantasy App. All rights reserved.
//

struct CollectionOffer: Codable {
    
    let id: String
    let deckName: String
    let deckOffers: [Offer]
}

extension CollectionOffer {
    
    struct Offer: Codable {
        let name: String
        let currentDeck: String
        let specialDeck: String
        let specialAnalyticsName: String
        let triggerCount: Int
        let isEnabled: Bool
    }
}
