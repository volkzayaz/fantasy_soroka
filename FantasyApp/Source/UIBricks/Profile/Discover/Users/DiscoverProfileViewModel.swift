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
        case profiles
        case noLocationPermission
        case absentCommunity(nearestCity: String?)
        case noSearchPreferences
    }
    
    var mode: Driver<Mode> {
        
        return locationActor.needsLocationPermission
            .flatMapLatest { status -> Driver<Mode?> in
                
                guard status == false else {
                    return .just(.noLocationPermission)
                }

                return Driver
                    .combineLatest(self.locationActor.near,
                                   appState.map { $0.currentUser?.searchPreferences == nil }) { ($0, $1) }
                    .map { (near, isFilterEmpty) -> Mode? in
                        
                        switch near {

                        case .bigCity(let name)?:
                            return .absentCommunity(nearestCity: name)

                        case .none:
                            return .absentCommunity(nearestCity: nil)
                            
                        case .community(_)?: break

                        }
                        
                        if isFilterEmpty {
                            return .noSearchPreferences
                        }
                        
                        return .profiles
                        
                    }
            }
            .notNil()
        
    }
    
    var profiles: Driver<[Profile]> {

        return appState
            .changesOf { $0.currentUser?.discoveryFilter }
            .notNil()
            .flatMapLatest { [unowned i = indicator] (filter) -> Driver<[Profile]> in
                
                return DiscoveryManager.profilesFor(filter: filter)
                    .trackView(viewIndicator: i)
                    .asDriver(onErrorJustReturn: [])
                
            }
            .asDriver(onErrorJustReturn: [])
    }

    
}

struct DiscoverProfileViewModel : MVVM_ViewModel {
    
    fileprivate var viewedProfiles: Set<Profile> = []
    
    let locationActor = PickCommunityViewModel()
    
    init(router: DiscoverProfileRouter) {
        self.router = router
        
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
    }
    
    func profileSelected(_ profile: Profile) {
        router.presentProfile(profile)
    }
    
    func presentFilter() {
        router.presentFilter( )
    }
    
}

