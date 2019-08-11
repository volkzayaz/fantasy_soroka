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
    
}

struct LocationActor {
    
    private let manager = CLLocationManager()
    
    init() {
        
        manager.requestWhenInUseAuthorization()
        manager.startMonitoringSignificantLocationChanges()
        
        manager.rx.location
            .notNil()
            .subscribe(onNext: { (x) in
                Dispatcher.dispatch(action: UpdateLocation(with: x))
            })
            .disposed(by: bag)
        
    }
    
    private let bag = DisposeBag()
}
