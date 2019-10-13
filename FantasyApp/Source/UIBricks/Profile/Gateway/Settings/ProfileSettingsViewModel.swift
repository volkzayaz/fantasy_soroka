//
//  ProfileSettingsViewModel.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/29/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa

extension ProfileSettingsViewModel {
    
    /** Reference binding drivers that are going to be used in the corresponding view
    
    var text: Driver<String> {
        return privateTextVar.asDriver().notNil()
    }
 
     */
    
}

struct ProfileSettingsViewModel : MVVM_ViewModel {
    
    /** Reference dependent viewModels, managers, stores, tracking variables...
     
     fileprivate let privateDependency = Dependency()
     
     fileprivate let privateTextVar = BehaviourRelay<String?>(nil)
     
     */
    
    init(router: ProfileSettingsRouter) {
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
    
    let router: ProfileSettingsRouter
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
    
}

extension ProfileSettingsViewModel {
    
    func logout() {
        AuthenticationManager.logout()
        Dispatcher.dispatch(action: Logout())
    }
    
    func deleteAccount() {
        
        router.owner.showDialog(title: "Delete account?",
                                text: "You will be logged out. All your data will be erased. This can not be undone", style: .alert, negativeText: "Cancel", negativeCallback: nil, positiveText: "Delete account") {
            
            let _ = UserManager.deleteAccount()
                .trackView(viewIndicator: self.indicator)
                .silentCatch(handler: self.router.owner)
                .subscribe(onNext: self.logout)
            
        }
        
    }

    func restorePurchases() {
        PurchaseManager.restorePurchases()
        .trackView(viewIndicator: indicator)
            .silentCatch(handler: router.owner)
            .subscribe()
            .disposed(by: bag)
    }
    
}
