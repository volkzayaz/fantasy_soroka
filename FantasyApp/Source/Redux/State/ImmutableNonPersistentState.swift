//
//  ImmutableNonPersistentState.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 29.11.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

////only mutated by FetchConfig() from MainTabViewModel
var immutableNonPersistentState: ImmutableNonPersistentState!

struct ImmutableNonPersistentState {
    
    let subscriptionProductID: String
    let screenProtectEnabled: Bool

    let shareCardImageURL: String
    let shareCollectionImageURL: String
    
}
