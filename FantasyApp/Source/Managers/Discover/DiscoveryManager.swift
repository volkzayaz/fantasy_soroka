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
                
                let noGo = /*response.map { $0.otherUserId } +*/ [User.current!.id]
                
                var query =  User.query
                    .whereKey("objectId", notContainedIn: noGo)
                    .whereKey("belongsTo", equalTo: filter.community.pfObject)
                    .whereKey("gender", equalTo: filter.filter.gender.rawValue)
                    .whereKey("isBlocked", notEqualTo: NSNumber(booleanLiteral: true))
                    .whereKey("flirtAccess", notEqualTo: false)
                
                if filter.filter.sexualityV2 != .all {
                    query = query.whereKey("sexuality", equalTo: filter.filter.sexualityV2.rawValue)
                }
                
                if let minDate = Calendar.current.date(byAdding: .year, value: -filter.filter.age.upperBound, to: Date()) {
                    query = query.whereKey("birthday", greaterThan: minDate)
                }
                
                if let maxDate = Calendar.current.date(byAdding: .year, value: -filter.filter.age.lowerBound, to: Date()) {
                    query = query.whereKey("birthday", lessThan: maxDate)
                }
                    
                return query.rx.fetchAllObjects()
            }
            .map { x in
                return x.compactMap { try? User(pfUser: $0 as! PFUser) }
            }
        
    }

}
