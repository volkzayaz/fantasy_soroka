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
    
    static func profilesFor(filter: DiscoveryFilter, isViewed: Bool) -> Single<[UserProfile]> {

        UsersResource(discoveryFilter: filter, isViewed: isViewed).rx.request
            .map { $0.users }
    }
    
    static func searchSwipeState() -> Single<SearchSwipeState> {
        UserSearchSwipeStateResource().rx.request
    }
    
    static func markUserIsViewedInSearch(_ user: UserIdentifier) -> Single<Void> {
        UserViewSearchResource(user: user).rx.request.map { _ in }
    }
    
    static func markUserProfileIsViewed(_ user: UserIdentifier) -> Single<Void> {
        UserViewProfileResource(user: user).rx.request.map { _ in }
    }
}
