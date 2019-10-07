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

extension MyFantasiesSettingsViewModel {
    
    /** Reference binding drivers that are going to be used in the corresponding view
    
    var text: Driver<String> {
        return privateTextVar.asDriver().notNil()
    }
 
     */
    
}

struct MyFantasiesSettingsViewModel : MVVM_ViewModel {
    
    /** Reference dependent viewModels, managers, stores, tracking variables...
     
     fileprivate let privateDependency = Dependency()
     
     fileprivate let privateTextVar = BehaviourRelay<String?>(nil)
     
     */
    
    init(router: MyFantasiesSettingsRouter) {
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
    
    let router: MyFantasiesSettingsRouter
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
    
}

extension MyFantasiesSettingsViewModel {
    
    /** Reference any actions ViewModel can handle
     ** Actions should always be void funcs
     ** any result should be reflected via corresponding drivers
     
     func buttonPressed(labelValue: String) {
     
     }
     
     */
    
}
