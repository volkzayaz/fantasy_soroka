//
//  MyFantasiesReactionHistoryViewModel.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 10/6/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa

class MyFantasiesBlockedViewModel : MVVM_ViewModel {

    init(router: MyFantasiesBlockedRouter) {
        self.router = router
        
        indicator.asDriver()
            .drive(onNext: { [weak h = router.owner] (loading) in
                h?.setLoadingStatus(loading)
            })
            .disposed(by: bag)
    }
    
    let router: MyFantasiesBlockedRouter
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
    
}
