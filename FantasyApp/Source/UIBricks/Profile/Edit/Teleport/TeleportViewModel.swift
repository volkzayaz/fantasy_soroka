//
//  TeleportViewModel.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/18/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import RxDataSources

extension TeleportViewModel {
    
    var dataSource: Driver<[AnimatableSectionModel<String, Data>]> {
        
        let communitySection: Driver<[Data]> = appState
            .changesOf { $0.currentUser?.community }
            .notNil()
            .flatMapLatest { x in
                
                guard let lastKnownLocation = x.lastKnownLocation else {
                    return .just([Data.location(title: "My Current Loction",
                                                subtitle: "Not determined",
                                                isSelected: false,
                                                icon: R.image.currentLocation()!)])
                }
                
                return CLGeocoder().rx.city(near: lastKnownLocation.clLocation)
                    .asDriver(onErrorJustReturn: nil)
                    .map { maybeCurrentPhysicalLocation in
                        
                        guard let currentLocation = maybeCurrentPhysicalLocation else {
                            return [Data.location(title: "My Current Loction",
                                                  subtitle: "Unknown location",
                                                  isSelected: true,
                                                  icon: R.image.currentLocation()!)]
                        }
                        
                        let didGuyTeleported: Bool = x.changePolicy == .teleport
                        
                        var response: [Data] = [ .location(title: "My Current Loction",
                                                           subtitle: currentLocation,
                                                           isSelected: !didGuyTeleported,
                                                           icon: R.image.currentLocation()!) ]
                        
                        if let community = x.value, didGuyTeleported {
                            response.append( .location(title: community.name,
                                                       subtitle: community.country,
                                                       isSelected: true,
                                                       icon: R.image.teleportedLocation()! ) )
                        }
                        
                        return response
                        
                }
        }
        
        let data = CommunityManager.allCommunities()
                                   .trackView(viewIndicator: indicator)
                                   .silentCatch()
                                   .map { Dictionary(grouping: $0, by: { $0.country }) }
                                   .asDriver(onErrorJustReturn: [:])

        return Driver.combineLatest(mode.asDriver(),
                                    data,
                                    communitySection)
                .map { (mode, data, communitySection) in
                    
                    switch mode {
                    case .countries:
                        return [
                            AnimatableSectionModel(model: "current location",
                                                   items: communitySection),
                            
                            AnimatableSectionModel(model: "available locations",
                                                   items: data
                                                    .sorted { $0.value.first!.sortOrder < $1.value.first!.sortOrder }
                                                    .map { Data.country($0.key, $0.value.count) }
                                )
                                
                        ]
                        
                    case .communities(let fromCountry):
                        return [
                            AnimatableSectionModel(model: "current location",
                                                   items: communitySection),
                            
                            AnimatableSectionModel(model: "available locations",
                            items: (data[fromCountry] ?? []).sorted(by: { $0.name < $1.name }).map { Data.community($0) })
                        ]
                        
                    }
                    
                }
        
    }
    
    var upgradeButtonHidden: Driver<Bool> {
        return appState.changesOf { $0.currentUser?.subscription.isSubscribed }
            .map { $0 ?? false }
    }
    
    enum Data: IdentifiableType, Equatable {
        case community(Community)
        case country(String, Int)
        case location(title: String, subtitle: String, isSelected: Bool, icon: UIImage)
        
        var identity: String {
            switch self {
            case .community(let x):  return x.name + x.country
            case .country(let x, _): return x
            case .location(let t, let x, _, _): return "currentLocation" + t + x
            }
        }
        
    }
    
    enum Mode {
        case countries
        case communities(fromCountry: String)
    }
    
}

struct TeleportViewModel : MVVM_ViewModel {
    
    fileprivate let mode = BehaviorRelay(value: Mode.countries)
    
    enum Response {
        case editForm(BehaviorRelay<EditProfileForm>)
        case directApplication
    }
    
    fileprivate let response: Response
    
    init(router: TeleportRouter, response: Response) {
        self.router = router
        self.response = response
        
        /////progress indicator
        
        indicator.asDriver()
            .drive(onNext: { [weak h = router.owner] (loading) in
                h?.setLoadingStatus(loading)
            })
            .disposed(by: bag)
    }
    
    let router: TeleportRouter
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
    
}

extension TeleportViewModel {
    
    func selected(data: Data) {
        
        let x: User.Community
        let requiresSubscriptionCheck: Bool
        switch data {
            
        case .country(let country, _):
            return mode.accept(.communities(fromCountry: country))
            
        case .community(let community):
            requiresSubscriptionCheck = true
            x = User.Community(value: community,
                               changePolicy: .teleport,
                               lastKnownLocation: User.current?.community.lastKnownLocation)
        
        case .location(let title, _, _, _):
            
            ///TODO: this meant to be: "do not react if user clicks on teleported cell"
            guard title == "My Current Loction" else {
                return
            }
            
            requiresSubscriptionCheck = false
            x = User.Community(value: nil,
                               changePolicy: .locationBased,
                               lastKnownLocation: User.current?.community.lastKnownLocation)
            
        }
        
        guard !requiresSubscriptionCheck || (User.current?.subscription.isSubscribed ?? false) else {
            return router.showSubscription()
        }
        
        switch response {
        case .editForm(let form):
            var y = form.value
            y.communityChange = x
            form.accept(y)
            
        case .directApplication:
            
            var u = User.current!
            u.community = x
            Dispatcher.dispatch(action: SetUser(user: u))
            
            let _ = UserManager.save(user: u).subscribe()
            
        }
        
        router.popBack()
        
    }
    
    func back() {
        
        if case .communities(_) = mode.value {
            return mode.accept(.countries)
        }

        router.popBack()
        
    }
    
}
