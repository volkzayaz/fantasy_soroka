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

extension DiscoverProfileViewModel {
    
    enum Mode: Equatable {
        case profiles
        case noLocationPermission
        case absentCommunity(nearestCity: String?)
        case noSearchPreferences
        case activateFlirtAccess
    }
    
    struct ProfilesState {
        let profiles: [UserProfile]
        let initialIndex: Int?
        let isDailyLimitReached: Bool
    }
    
    var mode: Driver<Mode> {
        let defaultMode: Driver<Mode> = .just(.activateFlirtAccess)
        let mode: Driver<Mode> = Driver.combineLatest(
            appState.changesOf { $0.currentUser?.bio.flirtAccess },
            locationActor.needsLocationPermission,
            locationActor.near,
            appState.changesOf { $0.currentUser?.searchPreferences == nil },
            appState.changesOf { $0.currentUser?.subscription.isSubscribed == true }
        ).map { flirtAccess, locationPermission, near, isFilterEmpty, isSubscribed in
            guard flirtAccess != false else {
                return .activateFlirtAccess
            }
            
            guard locationPermission == false else {
                return .noLocationPermission
            }
            
            if !isSubscribed {
                switch near {
                case .bigCity(let name)?: return .absentCommunity(nearestCity: name)
                case .none: return .absentCommunity(nearestCity: nil)
                case .community(_)?: break
                }
            }

            if isFilterEmpty {
                return .noSearchPreferences
            }

            return .profiles
        }
        
        return Driver.concat([defaultMode, mode])
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
            appState.changesOf { $0.currentUser?.discoveryFilter?.filter.isGlobalMode }
                .map { $0 == true },
            mode.map { (m) -> Bool in
                switch m {
                case .noSearchPreferences, .noLocationPermission, .activateFlirtAccess: return false
                default:  return true
                }
        }){ ($0, $1, $2) }
            .map { ($0.0 || $0.1) && $0.2 }
    }
    
    var limitExpirationDate: Driver<Date?> {
        searchSwipeState
            .map { $0?.wouldBeUpdatedAt }
            .asDriver(onErrorJustReturn: nil)
    }
    
    var isSubscriptionHidden: Driver<Bool> {
        return appState.changesOf { $0.currentUser?.subscription.isSubscribed }
            .map { $0 ?? false }
    }
}

class DiscoverProfileViewModel : MVVM_ViewModel {
    
    let profilesState = BehaviorRelay<ProfilesState>(value: ProfilesState(profiles: [], initialIndex: nil, isDailyLimitReached: false))
    
    private var viewedProfiles: Set<UserProfile> = []
    private var searchSwipeState = BehaviorRelay<SearchSwipeState?>(value: nil)
    private let form = BehaviorRelay(value: EditProfileForm(answers: User.current!.bio.answers))

    let locationActor = PickCommunityViewModel()
    
    init(router: DiscoverProfileRouter) {
        self.router = router
        
        Observable.combineLatest(
            appState.changesOf { $0.currentUser?.discoveryFilter }
                .notNil()
                .asObservable(),
            appState.changesOf { $0.currentUser?.subscription.isSubscribed }
                .asObservable(),
            updateProfiles
                .startWith(())
        ).flatMapLatest { [unowned i = indicator] filter, _, _ in
            Observable.combineLatest(
                DiscoveryManager.profilesFor(filter: filter, isViewed: true).asObservable(),
                DiscoveryManager.profilesFor(filter: filter, isViewed: false).asObservable(),
                DiscoveryManager.searchSwipeState().map { $0 as SearchSwipeState? }.asObservable()
            ).trackView(viewIndicator: i)
        }.silentCatch(handler: router.owner)
        .asDriver(onErrorJustReturn: ([], [], nil))
        .drive(onNext: { [unowned self] (viewedProfiles, newProfiles, searchSwipeState) in
            let availableNewProfiles = Array(newProfiles.prefix(searchSwipeState?.amount ?? 0))
            let profiles = viewedProfiles.reversed() + availableNewProfiles
            let initialIndex = profiles.firstIndex(where: { $0.isViewed == false })
            
            var isDailyLimitReached: Bool
            if let availableSwipesAmount = searchSwipeState?.amount {
                isDailyLimitReached = availableSwipesAmount <= newProfiles.count
            } else {
                isDailyLimitReached = false
            }
            
            self.profilesState.accept(ProfilesState(profiles: profiles, initialIndex: initialIndex, isDailyLimitReached: isDailyLimitReached))
            self.searchSwipeState.accept(searchSwipeState)
            self.viewedProfiles.removeAll()
        }).disposed(by: bag)
        
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
    
    func profileViewed(index: Int) {
        guard let profile = profilesState.value.profiles[safe: index], profile.isViewed != true && !viewedProfiles.contains(profile) else { return }
        
        viewedProfiles.insert(profile)
        DiscoveryManager.markUserIsViewedInSearch(profile)
            .subscribe(onSuccess: { [unowned self] state in
                self.searchSwipeState.accept(state)
                
                let availableProfilesNumber = self.profilesState.value.profiles.filter { $0.isViewed == true }.count + self.viewedProfiles.count + state.amount
                if availableProfilesNumber < self.profilesState.value.profiles.count {
                    let availableProfiles = Array(self.profilesState.value.profiles.prefix(availableProfilesNumber))
                    self.profilesState.accept(ProfilesState(profiles: availableProfiles, initialIndex: index, isDailyLimitReached: true))
                }
            }).disposed(by: bag)
    }
    
    func profileSelected(index: Int) {
        guard let profile = self.profilesState.value.profiles[safe: index] else { return }
        
        router.presentProfile(profile, onInitiateConnection: { [weak self] in
            guard let `self` = self else { return }
            
            if let currentProfileIndex = self.profilesState.value.profiles.firstIndex(of: profile) {
                var updatedProfiles = self.profilesState.value.profiles
                updatedProfiles.remove(at: currentProfileIndex)
                self.profilesState.accept(ProfilesState(profiles: updatedProfiles, initialIndex: index, isDailyLimitReached: self.profilesState.value.isDailyLimitReached))
                self.viewedProfiles.remove(profile)
            }
        })
        
        _ = DiscoveryManager.markUserProfileIsViewed(profile).subscribe()
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
    
    func subscribeTapped() {
        router.showSubscription(page: .x3NewProfilesDaily)
    }
    
    func goGlobal() {
        router.showSubscription(page: .globalMode)
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

private extension DiscoverProfileViewModel {
    
    var updateProfiles: Observable<Void> {
        searchSwipeState
            .map { $0?.wouldBeUpdatedAt }
            .notNil()
            .flatMapLatest { wouldBeUpdatedAt -> Observable<Void> in
                let updateInterval: TimeInterval = max(ceil(wouldBeUpdatedAt.timeIntervalSince(Date())), 10)
                return Observable<Int>.interval(.seconds(Int(updateInterval)), scheduler: MainScheduler.instance)
                    .take(1)
                    .map { _ in }
            }
    }
}
