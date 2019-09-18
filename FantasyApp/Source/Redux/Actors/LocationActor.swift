//
//  LocationActor.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 7/30/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import CoreLocation
import RxSwift
import RxCocoa
import RxCoreLocation

extension LocationActor {
    
    var lastKnownAuthStatus: Driver<CLAuthorizationStatus> {
        return manager.rx.didChangeAuthorization.map { $0.status }
            .asDriver(onErrorJustReturn: .notDetermined)
    }
    
    var near: Driver<Near?> {
        
        return manager.rx.location
            .notNil()
            .flatMapLatest { (newLocation) in
                return CommunityManager.communities(near: newLocation)
                    .asObservable().map { ($0, newLocation) }
            }
            .flatMapLatest { (arg) -> Observable<Near?> in
                
                let (communities, location) = arg
                
                if communities.count > 0 {
                    return .just(.communities(communities))
                }
                
                return CLGeocoder().rx.city(near: location)
                    .asObservable()
                    .map { x -> Near? in
                        if let x = x { return .bigCity(name: x) }
                        
                        return nil
                    }
                
            }
            .asDriver(onErrorJustReturn: nil)
        
    }
    
    enum Near {
        case communities([Community])
        case bigCity(name: String)
    }
    
}

struct LocationActor {
    
    private let manager = CLLocationManager()
    
    init() {
        
        manager.requestWhenInUseAuthorization()
        manager.startMonitoringSignificantLocationChanges()
        
        
    }
    
    private let bag = DisposeBag()
}
