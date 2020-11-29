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
    
    enum Mode: Equatable {
        case profiles
        case noLocationPermission
        case absentCommunity(nearestCity: String?)
        case noSearchPreferences
        case activateFlirtAccess
    }
    
    var mode: Driver<Mode> {
        return Driver.combineLatest(
            appState.changesOf { $0.currentUser?.bio.flirtAccess },
            locationActor.needsLocationPermission,
            locationActor.near,
            appState.map { $0.currentUser?.searchPreferences == nil }
        ).map { flirtAccess, locationPermission, near, isFilterEmpty in
                    
            guard flirtAccess != false else {
                return .activateFlirtAccess
            }
            
            guard locationPermission == false else {
                return .noLocationPermission
            }
            
            switch near {
            case .bigCity(let name)?: return .absentCommunity(nearestCity: name)
            case .none: return .absentCommunity(nearestCity: nil)
            case .community(_)?: break
            }

            if isFilterEmpty {
                return .noSearchPreferences
            }

            return .profiles
        }
    }
    
    var autoOpenFlirtOptions: Driver<Void> {
        if let user = appStateSlice.currentUser, PerformManager.willPerform(rule: .once, event: .flirtOptionsShownInFlirt, accessLevel: .local(id: user.id)) {
            return mode.filter { $0 == .noSearchPreferences }
                .map { _ in }
                .asObservable()
                .take(1)
                .asDriver(onErrorJustReturn: ())
        } else {
            return Driver.empty()
        }
    }
    
    var filterButtonEnabled: Driver<Bool> {
        
        return Driver.combineLatest(
            appState.changesOf { $0.currentUser?.community.value }
                .map { $0 != nil },
            mode.map { (m) -> Bool in
                switch m {
                case .noSearchPreferences, .noLocationPermission, .activateFlirtAccess: return false
                default:  return true
                }
        }){ ($0, $1) }
            .map { $0.0 && $0.1}
    }
}

class DiscoverProfileViewModel : MVVM_ViewModel {
    
    let profiles = BehaviorRelay<[Profile]>(value: [])
    
    fileprivate var viewedProfiles: Set<Profile> = []
    fileprivate let form = BehaviorRelay(value: EditProfileForm(answers: User.current!.bio.answers))

    let locationActor = PickCommunityViewModel()
    
    init(router: DiscoverProfileRouter) {
        self.router = router
        
        appState.changesOf { $0.currentUser?.discoveryFilter }
            .notNil()
            .flatMapLatest { [unowned i = indicator] (filter) -> Driver<[Profile]> in
                
                return DiscoveryManager.profilesFor(filter: filter)
                    .trackView(viewIndicator: i)
                    .asDriver(onErrorJustReturn: [])
                
        }
        .asDriver(onErrorJustReturn: [])
        .drive(profiles)
        .disposed(by: bag)
        
        /////progress indicator
        
        indicator.asDriver()
            .drive(onNext: { [weak h = router.owner] (loading) in
                h?.setLoadingStatus(loading)
            })
            .disposed(by: bag)
        
        form.skip(1) // initial value
            .flatMapLatest { form in
                return UserManager.submitEdits(form: form)
                    .silentCatch(handler: router.owner)
            }
            .subscribe(onNext: { (user) in
                Dispatcher.dispatch(action: SetUser(user: user))
            })
            .disposed(by: bag)
    }
    
    let router: DiscoverProfileRouter
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
}

//MARK:- Actions

extension DiscoverProfileViewModel {
    
    func profileSwiped(profile: Profile) {
        guard !viewedProfiles.contains(profile) else { return }
        
        viewedProfiles.insert(profile)
    }
    
    func profileSelected(_ profile: Profile) {
        router.presentProfile(profile)
    }
    
    func presentFilter() {
        self.router.presentFilter()
    }
    
    func autopresentFilter() {
        if self.router.canPresent, let user = appStateSlice.currentUser {
            PerformManager.perform(rule: .once, event: .flirtOptionsShownInFlirt, accessLevel: .local(id: user.id)) {
                self.router.presentFilter()
            }
        }
    }
    
    func inviteFriends() {
        router.invite(
            [R.string.localizable.roomBranchObjectDescription(),
             NSURL(string: "http://bit.ly/fantasymatch")!
        ])
    }
    
    func joinActiveCity() {
        router.openTeleport()
    }
    
    // Location
    
    func goToSettings() {
        UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
    }
    
    func allowLocationService() {
        
    }
    
    func notAllowLocationService() {
        
    }
    
    func viewDidAppear() {
        // Dispatch async to avoid presenting at the same time as Filter Options are presented
        DispatchQueue.main.async {
            guard appStateSlice.currentUser?.subscription.isSubscribed == false, self.router.canPresent else { return }
            
            PerformManager.perform(rule: .on(RemoteConfigManager.subscriptionOfferPromoShownInFlirtAfterNumber), event: .subscriptionPromoOfferShownInFlirt) {
                self.router.presentSubscriptionLimitedOffer(offerType: .promo)
            }
            
            PerformManager.perform(rule: .on(RemoteConfigManager.subscriptionOfferSpecialShownInFlirtAfterNumber), event: .subscriptionSpecialOfferShownInFlirt) {
                self.router.presentSubscriptionLimitedOffer(offerType: .special)
            }
        }
    }
    
    func activateFlirtAccess() {
        var x = form.value
        x.flirtAccess = true
        form.accept(x)
        Analytics.report(Analytics.Event.FlirtAccess(isActivated: true))
    }
}
