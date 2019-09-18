//
//  MainTabBarViewModel.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 7/27/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa

extension MainTabBarViewModel {
    
    var locationRequestHidden: Driver<Bool> {
        return locationActor.lastKnownAuthStatus.map { x in
            return x != .denied
        }
        .distinctUntilChanged()
    }
 
}

struct MainTabBarViewModel : MVVM_ViewModel {

    private let locationActor = LocationActor()
    
    init(router: MainTabBarRouter) {
        self.router = router
        
        ///Refresh on app start happens here:
        ///Alternativelly we can encode appState to disk and just restore it from there
        ///To keep syncing problems at min for now we'll fetch most info from server
        ///But for v2 we want to implement disk-first retoration policy
        Fantasy.Manager.fetchSwipeState()
            .trackView(viewIndicator: indicator)
            .subscribe(onNext: { x in
                Dispatcher.dispatch(action: ResetSwipeRestriction(restriction: x))
            })
            .disposed(by: bag)
        
        Fantasy.Manager.fetchMainCards(localLimit: 20)
            .trackView(viewIndicator: indicator)
            .subscribe(onNext: { x in
                Dispatcher.dispatch(action: StoreMainCards(cards: x))
            })
            .disposed(by: bag)
        
        /**
         
         Proceed with initialization here
         
         */
        
        /////progress indicator
        
        indicator.asDriver()
            .drive(onNext: { [weak h = router.owner] (loading) in
                h?.setLoadingStatus(loading)
            })
            .disposed(by: bag)
    }
    
    let router: MainTabBarRouter
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
    
}

extension MainTabBarViewModel {
    
    /** Reference any actions ViewModel can handle
     ** Actions should always be void funcs
     ** any result should be reflected via corresponding drivers
     
     func buttonPressed(labelValue: String) {
     
     }
     
     */
    
}
