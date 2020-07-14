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
        static let subscriptionOfferShownInFlirtAfterNumber = "subscription_offer_shown_in_flirt_after_number"
        static let subscriptionOfferSpecial = "subscription_offer_special"
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
    
    static var subscriptionOfferShownInFlirtAfterNumber: Int {
        RemoteConfig.remoteConfig().configValue(forKey: Key.subscriptionOfferShownInFlirtAfterNumber).numberValue?.intValue ?? 2
    }
    
    static var subscriptionOfferSpecial: SubscriptionOfferSpecial.Offer {
        let data = RemoteConfig.remoteConfig().configValue(forKey: Key.subscriptionOfferSpecial).dataValue
        
        do {
            let config = try decoder.decode(SubscriptionOfferSpecial.self, from: data)
            return config.currentOffer
        } catch {
            return SubscriptionOfferSpecial.Offer.default
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
