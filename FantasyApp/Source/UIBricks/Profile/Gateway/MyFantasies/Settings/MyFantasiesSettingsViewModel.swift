//
//  MyFantasiesSettingsViewModel.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 10/6/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa

struct MyFantasiesSettingsViewModel : MVVM_ViewModel {

    init(router: MyFantasiesSettingsRouter) {
        self.router = router

        indicator.asDriver()
            .drive(onNext: { [weak h = router.owner] (loading) in
                h?.setLoadingStatus(loading)
            })
            .disposed(by: bag)
    }
    
    let router: MyFantasiesSettingsRouter
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
}
