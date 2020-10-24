//
//  ImmutableNonPersistentState.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 29.11.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

////only mutated by FetchConfig() from MainTabViewModel
var immutableNonPersistentState: ImmutableNonPersistentState! {
    didSet {
        AppsFlyerManager.configure()
    }
}

struct ImmutableNonPersistentState {
    
    let subscriptionProductIDs: Set<String>?
    
    let screenProtectEnabled: Bool

    let shareCardImageURL: String
    let shareCollectionImageURL: String
    let isAppsFlyerEnabled: Bool
    
    let legal: Legal
    
    struct Legal {
        
        let title: String
        let description: String
        
    }
    
}

var premiumIds: Set<String> = [
    "com.fantasyapp.iosclient.iap.premium",
    "com.fantasyapp.iosclient.iap.premium.1month",
    "com.fantasyapp.iosclient.iap.premium.months3",
    "com.fantasyapp.iosclient.iap.premium.months6",
    "com.fantasyapp.iosclient.iap.premium.year"
]
