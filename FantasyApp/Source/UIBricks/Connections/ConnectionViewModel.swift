//
//  ConnectionViewModel.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/20/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa

extension ConnectionViewModel {
    
    var requests: Driver<[User]> {
        
        return reloadTrigger.asDriver().flatMapLatest { [unowned i = indicator] _ in
            return ConnectionManager.inboundRequests()
                .trackView(viewIndicator: i)
                .asDriver(onErrorJustReturn: [])
        }
        
    }
    
}

struct ConnectionViewModel : MVVM_ViewModel {
    
    fileprivate let reloadTrigger = BehaviorRelay<Void>(value: () )
    
    init(router: ConnectionRouter) {
        self.router = router
        
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
    
    let router: ConnectionRouter
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
    
}

extension ConnectionViewModel {
    
    func viewAppeared() {
        reloadTrigger.accept( () )
    }
    
    func show(user: User) {
        router.show(user: user)
    }
    
}
