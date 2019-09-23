//
//  CommunityManager.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/18/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift

enum CommunityManager {}
extension CommunityManager {
    
    static func communities(near point: CLLocation) -> Single<[Community]> {
        
        return Community.query
            .whereKey("center",
                      nearGeoPoint: .init(location: point),
                      withinKilometers: 50)
            .rx.fetchAll()
        
    }
    
    static func allCommunities() -> Single<[Community]> {
        return Community.query.rx.fetchAll()
    }
    
}
