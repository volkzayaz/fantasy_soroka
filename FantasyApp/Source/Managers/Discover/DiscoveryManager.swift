//
//  DiscoveryManager.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/9/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift

enum DiscoveryManager {}
extension DiscoveryManager {
    
    static func profilesFor(filter: DiscoverProfileViewModel.DiscoveryFilter?,
                            limit: Int) -> Single<[Profile]> {
        return .just( [] )
    }

    static func swipeState() -> Single<DiscoverProfileViewModel.SwipeState> {
        
        return .just( .tillDate( Date(timeIntervalSinceNow: 12345) ) )
    }
    
}
