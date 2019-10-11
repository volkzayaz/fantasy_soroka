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
    
    static func logBigCity(name: String, location: CLLocation) {
        
        guard let me = User.current?.id else { return }
        
        PFQuery(className: "CommunityLog")
            .whereKey("center",
                      nearGeoPoint: .init(location: location),
                      withinKilometers: 0.2)
                .rx.fetchFirstObject()
                .flatMap { (maybeLog: PFObject?) -> Single<Void> in
                
                    if let log = maybeLog {
                        var x = Set(log["users"] as! [String])
                        x.insert(me)
                        log["users"] = Array(x)
                        
                        return log.rxSave()
                    }

                    let log = PFObject(className: "CommunityLog")
                    log["users"] = [me]
                    log["center"] = PFGeoPoint(location: location)
                    log["name"] = name
                    
                    return [log].rxSave()
                }
                .subscribe()
        
    }
    
}
