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
    
    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    // MARK: - Internal
    
    static func fetch() {
        let duration: TimeInterval = 3600 // hour
        
        RemoteConfig.remoteConfig().fetch(withExpirationDuration: duration) { status, _ in
            switch status {
            case .success:
                RemoteConfig.remoteConfig().activate()
                
            default: return
            }
        }
    }
}
