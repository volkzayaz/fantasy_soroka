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
    
    static func profilesFor(filter: DiscoveryFilter,
                            limit: Int) -> Single<[Profile]> {
        
        guard let community = User.current?.community else {
            return .just([])
        }
        
        let q = User.query
        q.whereKey("belongsTo", equalTo: community.pfObject)
        q.whereKey("objectId", notEqualTo: User.current!.id)
        q.whereKey("gender", equalTo: filter.filter.gender.rawValue)
        q.limit = 50
        return q.rx.fetchAllObjects().map { x in
            return x.compactMap { try? User(pfUser: $0 as! PFUser) }
        }
        
    }

    static func swipeState() -> Single<DiscoverProfileViewModel.SwipeState> {
        
        return ServerBusinessLogic.SwipeState
            .query
            .whereKey("userId", equalTo: User.current!.id)
            .rx
            .fetchFirst()
            .flatMap { (maybeState: ServerBusinessLogic.SwipeState?) in
                
                ///fetch or create
                guard let x = maybeState else {
                    return ServerBusinessLogic.SwipeState().rxCreate()
                }
                
                return .just(x)
            }
            .map { ServerBusinessLogic.convertToNative(serverState: $0) }
        
    }
    
    static func updateSwipeState(_ state: DiscoverProfileViewModel.SwipeState) -> Single<Void> {
        return ServerBusinessLogic
            .applyNative(swipeState: state)
            .rxSave()
    }
    
}
