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
        static let decksOfferSpecial = "decks_offer_special"
        static let decksOfferPrice = "decks_offer_price"
        static let subscriptionPlans = "subscription_plans"
        static let fakeLocation = "fake_location"
    }
    
    enum LearnScreen: String {
        case feed, decks
    }
    
    enum SubscriptionPlansStyle: String, Decodable {
        case regular, trial, offer
    }
    
    static var learnDefaultScreen: LearnScreen {
        let value = RemoteConfig.remoteConfig().configValue(forKey: Key.learnDefaultScreen).stringValue ?? ""
        return LearnScreen(rawValue: value) ?? .feed
    }
    
    static var showPriceInDeck: Bool {
        RemoteConfig.remoteConfig().configValue(forKey: Key.showPriceInDeck).boolValue
    }
    
    static var subscriptionOfferPromoShownInFlirtAfterNumber: Int {
        RemoteConfig.remoteConfig().configValue(forKey: Key.subscriptionOfferPromoShownInFlirtAfterNumber).numberValue.intValue
    }
    
    static var subscriptionOfferSpecialShownInFlirtAfterNumber: Int {
        RemoteConfig.remoteConfig().configValue(forKey: Key.subscriptionOfferSpecialShownInFlirtAfterNumber).numberValue.intValue
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
    
    static var specialDecksOffer: [CollectionOffer] {
        let data = RemoteConfig.remoteConfig().configValue(forKey: Key.decksOfferSpecial).dataValue

        do {
            return try decoder.decode([CollectionOffer].self, from: data)
        } catch {
            return []
        }
    }
    
    static var priceDecksOffer: [CollectionOffer] {
        let data = RemoteConfig.remoteConfig().configValue(forKey: Key.decksOfferPrice).dataValue

        do {
            return try decoder.decode([CollectionOffer].self, from: data)
        } catch { 
            return []
        }
    }
    
    static var subscriptionPlansConfiguration: SubscriptionPlansConfiguration {
        let data = RemoteConfig.remoteConfig().configValue(forKey: Key.subscriptionPlans).dataValue

        do {
            return try decoder.decode(SubscriptionPlansConfiguration.self, from: data)
        } catch {
            return SubscriptionPlansConfiguration.default
        }
    }
    
    static var fakeLocation: User.LastKnownLocation {
        let data = RemoteConfig.remoteConfig().configValue(forKey: Key.fakeLocation).dataValue

        do {
            return try decoder.decode(User.LastKnownLocation.self, from: data)
        } catch {
            return User.LastKnownLocation(location: CLLocation(latitude: 46.460103, longitude: 30.4315963))
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
                RemoteConfig.remoteConfig().activate(completion: nil)
                
            default: return
            }
        }
    }
}
