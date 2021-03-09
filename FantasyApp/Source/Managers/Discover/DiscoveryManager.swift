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
    
    static func profilesFor(filter: DiscoveryFilter, isSubscribed: Bool, isViewed: Bool) -> Single<[UserProfile]> {
        UsersResource(discoveryFilter: filter, isSubscribed: isSubscribed, isViewed: isViewed).rx.request
            .map { $0.users }
    }
    
    static func searchSwipeState() -> Single<SearchSwipeState> {
        UserSearchSwipeStateResource().rx.request
    }
    
    static func markUserIsViewedInSearch(_ user: UserIdentifier) -> Single<SearchSwipeState> {
        UserViewSearchResource(user: user).rx.request
    }
    
    static func markUserProfileIsViewed(_ user: UserIdentifier) -> Single<Void> {
        UserViewProfileResource(user: user).rx.request.map { _ in }
    }
}
