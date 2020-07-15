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
    
    var currentSpecialOffer: Offer { subscriptionOffers.first(where: { $0.name == currentSubscriptionOffer }) ?? Offer.specialDefault }
    var currentPromoOffer: Offer { subscriptionOffers.first(where: { $0.name == currentSubscriptionOffer }) ?? Offer.promoDefault }
}

extension SubscriptionOfferSpecial {
    
    struct Offer: Codable {
        let name: String
        let currentProduct: String
        let specialProduct: String
        let specialAnalyticsName: String
        
        static let specialDefault = Offer(
            name: "SubscriptionOffer1wSpecial",
            currentProduct: "com.fantasyapp.iosclient.iap.premium",
            specialProduct: "com.fantasyapp.iosclient.iap.premium.special2",
            specialAnalyticsName: "Club Membership Weekly Special"
        )
        
        static let promoDefault = Offer(
             name: "SubscriptionOffer1wPromo",
             currentProduct: "com.fantasyapp.iosclient.iap.premium",
             specialProduct: "com.fantasyapp.iosclient.iap.premium.special",
             specialAnalyticsName: "Club Membership Weekly Promo"
         )
    }
}
