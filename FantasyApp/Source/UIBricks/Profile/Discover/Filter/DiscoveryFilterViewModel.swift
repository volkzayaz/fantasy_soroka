//
//  DiscoveryFilterViewModel.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/9/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa

extension DiscoveryFilterViewModel {
    
    /** Reference binding drivers that are going to be used in the corresponding view
    
    var text: Driver<String> {
        return privateTextVar.asDriver().notNil()
    }
 
     */
    
}

struct DiscoveryFilterViewModel : MVVM_ViewModel {
    
    fileprivate let filter: BehaviorRelay<DiscoveryFilter?>
    
    init(router: DiscoveryFilterRouter, filter: BehaviorRelay<DiscoveryFilter?>) {
        self.router = router
        self.filter = filter
        
        /**
         
         Proceed with initialization here
         
         */
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            
            ///example of passing data back to userProfiles screen
            filter.accept( DiscoveryFilter(age: 2..<5, radius: 12, gender: .male) )
            
        }
        
        /////progress indicator
        
        indicator.asDriver()
            .drive(onNext: { [weak h = router.owner] (loading) in
                h?.setLoadingStatus(loading)
            })
            .disposed(by: bag)
    }
    
    let router: DiscoveryFilterRouter
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
    
}

extension DiscoveryFilterViewModel {
    
    /** Reference any actions ViewModel can handle
     ** Actions should always be void funcs
     ** any result should be reflected via corresponding drivers
     
     func buttonPressed(labelValue: String) {
     
     }
     
     */
    
}
