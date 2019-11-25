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
        
        return mode.asDriver()
            .flatMapLatest { mode in
                
                return Driver.combineLatest(self.data.asDriver(),
                                            self.currentLocationName.asDriver()) { ($0, $1) }
                .map { (data, currentLocationName) in
                    
                    switch mode {
                    case .countries:
                        return [
                            AnimatableSectionModel(model: "current location",
                                                   items: [Data.location(currentLocationName)]),
                            
                            AnimatableSectionModel(model: "available locations",
                                                   items: data
                                                    .sorted { $0.value.first!.sortOrder < $1.value.first!.sortOrder }
                                                    .map { Data.country($0.key, $0.value.count) }
                                )
                                
                        ]
                        
                    case .communities(let fromCountry):
                        return [
                            AnimatableSectionModel(model: "current location",
                                                   items: [Data.location(currentLocationName)]),
                            
                            AnimatableSectionModel(model: "available locations",
                                                   items: (data[fromCountry] ?? []).map { Data.community($0) })
                        ]
                        
                    }
                    
                }
                
            }
        
    }
    
    enum Data: IdentifiableType, Equatable {
        case community(Community)
        case country(String, Int)
        case location(String)
        
        var identity: String {
            switch self {
            case .community(let x):  return x.name + x.country
            case .country(let x, _): return x
            case .location(let x):   return "currentLocation" + x
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
    fileprivate let data = BehaviorRelay<[String: [Community]]>(value: [:])
    fileprivate let currentLocationName = BehaviorRelay<String>(value: "")
    
    enum Response {
        case editForm(BehaviorRelay<EditProfileForm>)
        case directApplication
    }
    
    fileprivate let response: Response
    
    init(router: TeleportRouter, response: Response) {
        self.router = router
        self.response = response
        
        CommunityManager.allCommunities()
            .trackView(viewIndicator: indicator)
            .silentCatch()
            .map { Dictionary(grouping: $0, by: { $0.country }) }
            .bind(to: data)
            .disposed(by: bag)
        
        if let x = appStateSlice.currentUser?.community.lastKnownLocation {
            CLGeocoder().rx
                .city(near: CLLocation(latitude: x.latitude, longitude: x.longitude))
                .asObservable()
                .map { $0 ?? "" }
                .bind(to: currentLocationName)
                .disposed(by: bag)
        }
        
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
        
        switch data {
            
        case .country(let country, _):
            return mode.accept(.communities(fromCountry: country))
            
        case .community(let community):
            x = User.Community(value: community,
                               changePolicy: .teleport)
        
        case .location:
            x = User.Community(value: nil,
                               changePolicy: .locationBased)
            
        }
        
        guard (User.current?.subscription.isSubscribed ?? false) else {
            
            PurchaseManager.purhcaseSubscription()
                .trackView(viewIndicator: indicator)
                .silentCatch(handler: router.owner)
                .map { _ in data}
                .subscribe(onNext: self.selected)
                .disposed(by: bag)
            
            return
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
