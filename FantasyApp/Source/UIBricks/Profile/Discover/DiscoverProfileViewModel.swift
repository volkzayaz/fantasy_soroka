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
    }
    
    var mode: Driver<Mode> {
        
        return swipeState.asDriver().map { x -> Mode? in
            switch x {
            case .limit(_)?:    return .profiles
            case .tillDate(_)?: return .overTheLimit
            case .none:         return nil
            }
        }
        .notNil()
        
    }
    
    var profiles: Driver<[Profile]> {
        return filter.asDriver()
            .withLatestFrom(swipeState.asDriver()) { ($0, $1) }
            .flatMapLatest { (filter, swipeState) in
                
                guard case .limit(let x)? = swipeState else {
                    return .just([])
                }
                
                return DiscoveryManager.profilesFor(filter: filter,
                                                    limit: x)
                    .asDriver(onErrorJustReturn: [])
                
            }
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
    
    struct DiscoveryFilter {
        let age: Range<Int>
        let radius: CLLocationDistance
        let gender: Gender
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
    
    fileprivate let filter = BehaviorRelay<DiscoveryFilter?>(value: nil)
    fileprivate let swipeState = BehaviorRelay<SwipeState?>(value: nil)
    
    fileprivate var viewedProfiles: Set<Profile> = []
    
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
    }
    
    func profileSelected(_ profile: Profile) {
        router.presentProfile(profile)
    }
    
}
