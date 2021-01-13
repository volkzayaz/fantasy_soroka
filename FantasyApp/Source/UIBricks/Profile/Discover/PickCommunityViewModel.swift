//
//  PickCommunityViewModel.swift
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

extension PickCommunityViewModel {
    
    var needsLocationPermission: Driver<Bool> {
        
        return appState.changesOf { $0.currentUser?.community.changePolicy }
            .notNil()
            .flatMapLatest { policy in
                
                if case .teleport = policy {
                    return .just(false)
                }
                
                return self.manager.rx.didChangeAuthorization
                    .startWith((self.manager, CLLocationManager.authorizationStatus()))
                    .do(onNext: { (status) in
                        Analytics.report( Analytics.Event.LocationPermissionChange(authStatus: status.status) )
                    })
                    .map { $0.status == .denied }
                    .asDriver(onErrorJustReturn: false)
                    
            }
        
    }
    
    var near: Driver<Near?> {
        
        return appState.changesOf { $0.currentUser?.community.value }
            .flatMapLatest { maybeCommunity in
                
                if let c = maybeCommunity {
                    return .just( .community(c) )
                }
                
                return nearCurrentLocation
            }
        
    }
    
    enum Near {
        case community(Community)
        case bigCity(name: String)
    }
    
}

private extension PickCommunityViewModel {
    
    var nearCurrentLocation: Driver<Near?> {
        manager.rx.location
            .notNil()
            .map { location in
                if (RunScheme.debug || RunScheme.adhoc) && SettingsStore.disableLastKnownLocationUpdate.value, let lastKnownLocation = User.current?.community.lastKnownLocation {
                    return lastKnownLocation.clLocation
                } else {
                    return location
                }
            }.flatMapLatest { location in
                CLGeocoder().rx
                    .city(near: location)
                    .map { bigCity in
                        
                        guard let x = bigCity else {
                            return nil
                        }
                        
                        CommunityManager.logBigCity(name: x, location: location)
                        
                        _AnalyticsHackyTown = bigCity
                        
                        return Near.bigCity(name: x)
                    }
                
            }.asDriver(onErrorJustReturn: nil)
    }
}

struct PickCommunityViewModel {
    
    private let manager = CLLocationManager()
    
    init() {
        
        manager.requestWhenInUseAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        
        needsLocationPermission.filter { !$0 }
            .drive(onNext: { [weak m = manager] _ in
                m?.requestWhenInUseAuthorization()
            })
            .disposed(by: bag)
        
        ////reactions
        
        appState.changesOf { $0.currentUser?.community.changePolicy }
            .notNil()
            .drive(onNext: { [weak m = self.manager] (policy) in
                
                m?.startUpdatingLocation()
//                switch policy {
//                case .teleport:      m?.stopUpdatingLocation()
//                case .locationBased: m?.startUpdatingLocation()// startMonitoringSignificantLocationChanges()
//                }
                
            })
            .disposed(by: bag)
        
        ////Actions
        
        //CLLocation -> Community
        appState.changesOf { $0.currentUser?.community.changePolicy }
            .asObservable()
            .notNil()
            .flatMapLatest { [unowned m = self.manager] changePolicy -> Observable<CLLocation> in
                
                guard case .locationBased = changePolicy else {
                    return .never()
                }
                
                return m.rx.location
                    .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
                    .notNil()
                    .map { location in

                        ////TODO: we can manually predict if new location matches |community.value|
                        ////in this case there's no need for extra roundtrip to server
                        
                        if (RunScheme.debug || RunScheme.adhoc) && SettingsStore.disableLastKnownLocationUpdate.value, let lastKnownLocation = User.current?.community.lastKnownLocation {
                            return lastKnownLocation.clLocation
                        } else {
                            return location
                        }
                    }
                
            }
            .flatMapLatest { (newLocation) in
                return CommunityManager.communities(near: newLocation)
                    .asObservable()
                    .silentCatch()
            }
            .subscribe(onNext: { (communities) in
                Dispatcher.dispatch(action: UpdateCommunity(with: communities.first))
            })
            .disposed(by: bag)
        
        manager.rx.location
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .notNil()
            .subscribe(onNext: { (l) in
                Dispatcher.dispatch(action: UpdateLastKnownLocation(location: l))
            })
            .disposed(by: bag)
    }
    
    private let bag = DisposeBag()
}
