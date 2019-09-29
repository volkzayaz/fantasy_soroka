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
        
        let q = User.query
        q.whereKey("belongsTo", equalTo: filter.community.pfObject)
        q.whereKey("objectId", notEqualTo: User.current!.id)
        q.whereKey("gender", equalTo: filter.filter.gender.rawValue)
        return q.rx.fetchAllObjects().map { x in
            return x.compactMap { try? User(pfUser: $0 as! PFUser) }
        }
        
    }

}
