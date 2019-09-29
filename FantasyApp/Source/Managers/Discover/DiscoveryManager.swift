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
    
    static func profilesFor(filter: DiscoveryFilter) -> Single<[Profile]> {

        return GetAllConnections().rx.request
            .flatMap { (response) -> Single<[PFObject]> in
                
                let noGo = response.map { $0.otherUserId } + [User.current!.id]
                
                return User.query
                    .whereKey("objectId", notContainedIn: noGo)
                    .whereKey("belongsTo", equalTo: filter.community.pfObject)
                    .whereKey("gender", equalTo: filter.filter.gender.rawValue)
                    .rx.fetchAllObjects()
            }
            .map { x in
                return x.compactMap { try? User(pfUser: $0 as! PFUser) }
            }
        
    }

}
