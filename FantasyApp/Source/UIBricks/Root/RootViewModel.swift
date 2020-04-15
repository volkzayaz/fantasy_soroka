//
//  RootViewModel.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 7/27/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa

extension RootViewModel {
    
    var state: Driver<State> {
        
        let age = SettingsStore.ageRestriction.observable.asDriver(onErrorJustReturn: nil)
        
        let user = appState.changesOf { $0.currentUser }
                            .map { $0 == nil }
                            .distinctUntilChanged()
        
        return Driver.combineLatest(age, user,
                                    unsupportedVersionTriggerVar.asDriver(onErrorJustReturn: false)) { ($0, $1, $2) }
            .map { (maybeAge, user, isUnsupportedVersion) in
                
                if isUnsupportedVersion  { return .updateApp }
                
                guard maybeAge == nil else { return .ageRestriction }
                
                return user ? .authentication : .mainApp
            }
            .distinctUntilChanged()
    }
    
}

struct RootViewModel : MVVM_ViewModel {
    
    enum State {
        case authentication
        case mainApp
        
        case ageRestriction
        case updateApp
        
    }
    
    private let unsupportedVersionTriggerVar = BehaviorRelay(value: false)
    
    init(router: RootRouter) {
        self.router = router
        
        /**
         
         Proceed with initialization here
         
         */
        
        FetchConfig().rx.request
            .retry(2)
            .subscribe(onSuccess: { [weak t = unsupportedVersionTriggerVar] (config) in
                immutableNonPersistentState = .init(
                    subscriptionProductIDs: config.subscriptionProductIDs,
                    screenProtectEnabled: config.screenProtectEnabled,
                    shareCardImageURL: config.fantasyCardsShare.card,
                    shareCollectionImageURL: config.fantasyCardsShare.collection)
                t?.accept(CocoaVersion.current < config.minSupportedIOSVersion.cocoaVersion)
            })
            .disposed(by: bag)
        
        /////progress indicator
        
//        indicator.asDriver()
//            .drive(onNext: { [weak h = router.owner] (loading) in
//                h?.setLoadingStatus(loading)
//            })
//            .disposed(by: bag)
        
    }
    
    let router: RootRouter
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
    
}

extension RootViewModel {
    
    func triggerUpdate() {
        unsupportedVersionTriggerVar.accept(true)
    }
    
}
