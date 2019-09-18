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
    
//    var near: Observable<Near> {
//        
//        return manager.rx.location
//            .notNil()
//            .flatMapLatest { (newLocation) -> Observable<[Community]> in
//                return CommunityManager.communities(near: newLocation)
//                    .asObservable()
//            }
//            .flatMapLatest { communities -> Observable<Near> in
//                
//                if communities.count > 0 {
//                    return .just(.communities(communities))
//                }
//                
//                
//            }
//        
//    }
//    
    enum Near {
        case communities([Community])
        case bigCities([(name: String, center: CLLocationCoordinate2D)])
    }
    
}

struct LocationActor {
    
    private let manager = CLLocationManager()
    
    init() {
        
        manager.requestWhenInUseAuthorization()
        manager.startMonitoringSignificantLocationChanges()
        
        manager.rx.location
            .notNil()
            .flatMapLatest { (newLocation) -> Observable<[Community]> in
                return CommunityManager.communities(near: newLocation)
                    .asObservable()
            }
            .subscribe(onNext: { (x) in
                Dispatcher.dispatch(action: UpdateCommunity(with: x.first))
            })
            .disposed(by: bag)
        
    }
    
    private let bag = DisposeBag()
}
