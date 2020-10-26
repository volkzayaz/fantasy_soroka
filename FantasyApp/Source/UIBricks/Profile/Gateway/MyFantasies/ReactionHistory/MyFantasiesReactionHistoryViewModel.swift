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

class MyFantasiesReactionHistoryViewModel : MVVM_ViewModel {

    init(router: MyFantasiesReactionHistoryRouter) {
        self.router = router
        
        indicator.asDriver()
            .drive(onNext: { [weak h = router.owner] (loading) in
                h?.setLoadingStatus(loading)
            })
            .disposed(by: bag)
    }
    
    let router: MyFantasiesReactionHistoryRouter
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
    
}
