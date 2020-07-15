//
//  RemoteConfigService.swift
//  
//
//  Created by Vodolazkyi Anton on 6/7/20.
//  Copyright © 2020 Vodolazkyi. All rights reserved.
//

import FirebaseRemoteConfig

struct RemoteConfigManager {
    
    enum Key {
        static let showPriceInDeck = "collection_price_visible"
        static let learnDefaultScreen = "learn_default_screen"
        static let subscriptionOfferPromoShownInFlirtAfterNumber = "subscription_offer_promo_shown_in_flirt_after_number"
        static let subscriptionOfferSpecialShownInFlirtAfterNumber = "subscription_offer_special_shown_in_flirt_after_number"
        static let subscriptionOfferPromo = "subscription_offer_promo"
        static let subscriptionOfferSpecial  = "subscription_offer_special"
    }
    
    enum LearnScreen: String {
        case feed, decks
    }
    
    static var learnDefaultScreen: LearnScreen {
        let value = RemoteConfig.remoteConfig().configValue(forKey: Key.learnDefaultScreen).stringValue ?? ""
        return LearnScreen(rawValue: value) ?? .feed
    }
    
    static var showPriceInDeck: Bool {
        RemoteConfig.remoteConfig().configValue(forKey: Key.showPriceInDeck).boolValue
    }
    
    static var subscriptionOfferPromoShownInFlirtAfterNumber: Int {
        RemoteConfig.remoteConfig().configValue(forKey: Key.subscriptionOfferPromoShownInFlirtAfterNumber).numberValue?.intValue ?? 2
    }
    
    static var subscriptionOfferSpecialShownInFlirtAfterNumber: Int {
        RemoteConfig.remoteConfig().configValue(forKey: Key.subscriptionOfferSpecialShownInFlirtAfterNumber).numberValue?.intValue ?? 6
    }
    
    static var subscriptionOfferPromo: SubscriptionOfferSpecial.Offer {
        let data = RemoteConfig.remoteConfig().configValue(forKey: Key.subscriptionOfferPromo).dataValue
        
        do {
            let config = try decoder.decode(SubscriptionOfferSpecial.self, from: data)
            return config.currentPromoOffer
        } catch {
            return SubscriptionOfferSpecial.Offer.promoDefault
        }
    }
    
    static var subscriptionOfferSpecial: SubscriptionOfferSpecial.Offer {
        let data = RemoteConfig.remoteConfig().configValue(forKey: Key.subscriptionOfferSpecial).dataValue

        do {
            let config = try decoder.decode(SubscriptionOfferSpecial.self, from: data)
            return config.currentSpecialOffer
        } catch {
            return SubscriptionOfferSpecial.Offer.specialDefault
        }
    }

    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    // MARK: - Internal
    
    static func fetch() {
        let duration: TimeInterval = SettingsStore.environment.value == .production ? 3600 : 0
        
        RemoteConfig.remoteConfig().fetch(withExpirationDuration: duration) { status, _ in
            switch status {
            case .success:
                RemoteConfig.remoteConfig().activate()
                
            default: return
            }
        }
    }
}
