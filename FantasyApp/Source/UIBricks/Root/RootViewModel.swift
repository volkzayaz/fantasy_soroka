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
        return appState.changesOf { $0.currentUser }
            .map { $0 == nil }
            .distinctUntilChanged()
            .map { return $0 ? .authentication : .mainApp }
    }
    
}

struct RootViewModel : MVVM_ViewModel {
    
    enum State {
        case authentication
        case mainApp
    }
    
    init(router: RootRouter) {
        self.router = router
        
        /**
         
         Proceed with initialization here
         
         */
        
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
    
    /** Reference any actions ViewModel can handle
     ** Actions should always be void funcs
     ** any result should be reflected via corresponding drivers
     
     func buttonPressed(labelValue: String) {
     
     }
     
     */
    
}
