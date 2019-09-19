//
//  DiscoverProfileViewModel.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/9/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa

typealias Profile = User

extension DiscoverProfileViewModel {
    
    enum Mode {
        case profiles, overTheLimit
        case noLocationPermission
        case absentCommunity(nearestCity: String?)
        case noSearchPreferences
    }
    
    var mode: Driver<Mode> {
        
        return locationActor.lastKnownAuthStatus
            .flatMapLatest { status -> Driver<Mode?> in
                
                guard status != .denied else {
                    return .just(.noLocationPermission)
                }

                return Driver
                    .combineLatest(self.locationActor.near,
                                   self.swipeState.asDriver(),
                                   appState.map { $0.currentUser?.searchPreferences == nil }) { ($0, $1, $2) }
                    .map { (near, swipeState, isFilterEmpty) -> Mode? in
                        
                        switch near {
                            
                        case .bigCity(let name)?:
                            return .absentCommunity(nearestCity: name)
                            
                        case .none:
                            return .absentCommunity(nearestCity: nil)
                            
                        case .communities(let x)?:
                            Dispatcher.dispatch(action: UpdateCommunity(with: x.first))
                            
                        }
                        
                        if isFilterEmpty {
                            return .noSearchPreferences
                        }
                        
                        switch swipeState {
                        case .limit(_)?:    return .profiles
                        case .tillDate(_)?: return .overTheLimit
                        case .none:         return nil
                        }
                    }
            }
            .notNil()
        
    }
    
    /*
     
     -> Location Updates }
                          } Community
     -> Teleport Choice  }
     
 */
    
    var profiles: Driver<[Profile]> {

        return swipeState.notNil()
            .take(1)
            .flatMap { _ in
                return appState
                    .changesOf { $0.currentUser?.discoveryFilter }
                    .notNil()
            }
            .withLatestFrom(swipeState.asDriver().notNil()) { ($0, $1) }
            .flatMapLatest { [unowned i = indicator] (filter, swipeState) -> Driver<[Profile]> in
                
                guard case .limit(let x) = swipeState else {
                    return .just([])
                }
                
                return DiscoveryManager.profilesFor(filter: filter,
                                                    limit: x)
                    .trackView(viewIndicator: i)
                    .asDriver(onErrorJustReturn: [])
                
            }
            .asDriver(onErrorJustReturn: [])
    }
    
    var timeLeftText: Driver<String> {
        
        return swipeState.asDriver().notNil()
            .map { x -> Date? in
                if case .tillDate(let date) = x {
                    return date
                }
                return nil
            }
            .notNil()
            .flatMapLatest { date in
                
                return Driver<Int>.interval(.seconds(1)).map { _ in
                    
                    let secondsTillEnd = Int(date.timeIntervalSinceNow)
                    
                    let hours   =  secondsTillEnd / 3600
                    let minutes = (secondsTillEnd % 3600) / 60
                    let seconds = (secondsTillEnd % 3600) % 60
                    
                    return "\(hours):\(minutes):\(seconds)"
                }
                
        }
        
    }
    
    enum SwipeState {
        case limit(Int)
        case tillDate(Date)
        
        func decrement() -> SwipeState {
            switch self {
            case .tillDate(_): return self
            case .limit(let x):
                
                guard x - 1 > 0 else {
                    return .tillDate( Date(timeIntervalSinceNow: 3600 * 24) )
                }
                
                return .limit(x - 1)
            
            }
        }
        
    }
    
}

struct DiscoverProfileViewModel : MVVM_ViewModel {
    
    fileprivate let swipeState = BehaviorRelay<SwipeState?>(value: nil)
    
    fileprivate var viewedProfiles: Set<Profile> = []
    
    let locationActor = LocationViewModel()
    
    init(router: DiscoverProfileRouter) {
        self.router = router
        
        DiscoveryManager.swipeState()
            .trackView(viewIndicator: indicator)
            .silentCatch(handler: router.owner)
            .bind(to: swipeState)
            .disposed(by: bag)
        
        /////progress indicator
        
        indicator.asDriver()
            .drive(onNext: { [weak h = router.owner] (loading) in
                h?.setLoadingStatus(loading)
            })
            .disposed(by: bag)
    }
    
    let router: DiscoverProfileRouter
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
    
}

extension DiscoverProfileViewModel {
    
    mutating func profileSwiped(profile: Profile) {
        guard !viewedProfiles.contains(profile) else { return }
        
        viewedProfiles.insert(profile)
        swipeState.accept(swipeState.value?.decrement())
        
        ///might want to queue it up and debounce later
        _ = DiscoveryManager.updateSwipeState(swipeState.value!).subscribe()
    }
    
    func profileSelected(_ profile: Profile) {
        router.presentProfile(profile)
    }
    
    func presentFilter() {
        router.presentFilter( )
    }
    
}


