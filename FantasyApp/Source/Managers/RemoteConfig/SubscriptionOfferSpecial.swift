//
//  SubscriptionOfferSpecial.swift
//  FantasyApp
//
//  Created by Vodolazkyi Anton on 13.07.2020.
//  Copyright © 2020 Fantasy App. All rights reserved.
//

struct SubscriptionOfferSpecial: Codable {
    
    let currentSubscriptionOffer: String
    let subscriptionOffers: [Offer]
    
    var currentOffer: Offer { subscriptionOffers.first(where: { $0.name == currentSubscriptionOffer }) ?? Offer.default }
}

extension SubscriptionOfferSpecial {
    
    struct Offer: Codable {
        let name: String
        let currentProduct: String
        let specialProduct: String
        let specialAnalyticsName: String
        
        static let `default` = Offer(
            name: "SubscriptionOffer1wSpecial1",
            currentProduct: "com.fantasyapp.iosclient.iap.premium",
            specialProduct: "com.fantasyapp.iosclient.iap.premium.special",
            specialAnalyticsName: "Club Membership Weekly Special 1"
        )
    }
}
