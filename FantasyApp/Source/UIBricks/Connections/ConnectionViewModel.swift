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
import RxDataSources

extension ConnectionViewModel {
    
    var requests: Driver<[AnimatableSectionModel<String, ConnectedUser>]> {
        
        return Driver.combineLatest(reloadTrigger.asDriver(), source.asDriver()) { ($0, $1) }
            .flatMapLatest { [unowned i = indicator,
                              unowned o = router.owner] (_, source) in
                return ConnectionManager.connectionRequests(source: source)
                    .trackView(viewIndicator: i)
                    .silentCatch(handler: o)
                    .asDriver(onErrorJustReturn: [])
            }
            .map { [AnimatableSectionModel(model: "", items: $0)] }
        
    }
    
}

struct ConnectionViewModel : MVVM_ViewModel {
    
    fileprivate let reloadTrigger = BehaviorRelay<Void>(value: () )
    fileprivate let source = BehaviorRelay<GetConnectionRequests.Source>(value: .incomming )
    
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
    
    func sourceChanged( source: GetConnectionRequests.Source ) {
        self.source.accept(source)
    }
    
    func show(room: Chat.Room) {
        router.show(room: room)
    }
    
}
