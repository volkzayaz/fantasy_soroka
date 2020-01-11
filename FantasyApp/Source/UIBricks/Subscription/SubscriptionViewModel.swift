//
//  SubscriptionViewModel.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 10.01.2020.
//  Copyright © 2020 Fantasy App. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa

extension SubscriptionViewModel {
    
    /** Reference binding drivers that are going to be used in the corresponding view
    
    var text: Driver<String> {
        return privateTextVar.asDriver().notNil()
    }
 
     */
    
    enum Page: Int {
        case member = 0
        case unlimRooms
        case fantasyX3
        case screenProtect
        case teleport
    }
    
}

struct SubscriptionViewModel : MVVM_ViewModel {
    
    let startPage: Page
    
    init(router: SubscriptionRouter, page: Page) {
        self.router = router
        startPage = page
        
        Analytics.report(Analytics.Event.PurchaseInterest(context: page))
        
        /////progress indicator
        
        indicator.asDriver()
            .drive(onNext: { [weak h = router.owner] (loading) in
                h?.setLoadingStatus(loading)
            })
            .disposed(by: bag)
    }
    
    let router: SubscriptionRouter
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
    
}

extension SubscriptionViewModel {
    
    func subscribe() {
        
        PurchaseManager.purhcaseSubscription()
            .trackView(viewIndicator: indicator)
            .silentCatch(handler: router.owner)
            .subscribe(onNext: { [unowned o = router.owner] _ in
                o.dismiss(animated: true, completion: nil)
            })
            .disposed(by: self.bag)
        
    }
    
    /** Reference any actions ViewModel can handle
     ** Actions should always be void funcs
     ** any result should be reflected via corresponding drivers
     
     func buttonPressed(labelValue: String) {
     
     }
     
     */
    
}
