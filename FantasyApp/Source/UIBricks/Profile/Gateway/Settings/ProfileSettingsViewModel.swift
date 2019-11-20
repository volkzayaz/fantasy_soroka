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
import StoreKit

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

        let actions: [UIAlertAction] = [
            .init(title: "No", style: .cancel, handler: nil),
            .init(title: "Log out", style: .destructive, handler: { _ in
                AuthenticationManager.logout()
                Dispatcher.dispatch(action: Logout())
                self.router.dismiss()
            })
        ]

        router.owner.showDialog(title: "Log out", text: "You sure you want to log out from Fantasy app?", style: .alert, actions: actions)
    }
    
    func deleteAccount() {

        let actions: [UIAlertAction] = [
            .init(title: "Cancel", style: .cancel, handler: nil),
            .init(title: "Delete account", style: .destructive, handler: { _ in
                let _ = UserManager.deleteAccount()
                                   .trackView(viewIndicator: self.indicator)
                                   .silentCatch(handler: self.router.owner)
                                   .subscribe(onNext: self.logout)
            })
        ]

         router.owner.showDialog(title: "Delete account?", text: "You will be logged out. All your data will be erased. This can not be undone", style: .actionSheet, actions: actions)
    }

    func restorePurchases() {
        PurchaseManager.restorePurchases()
            .trackView(viewIndicator: indicator)
            .silentCatch(handler: router.owner)
            .subscribe()
            .disposed(by: bag)
    }

    func helpSupport() {
        guard let u = URL(string: R.string.localizable.fantasyConstantsHelpSupport()) else { return }
        router.showSafari(for: u)
    }

    func legal() {
        guard let u = URL(string: R.string.localizable.fantasyConstantsLegal()) else { return }
        router.showSafari(for: u)
    }

    func communityRules() {
        guard let u = URL(string: R.string.localizable.fantasyConstantsCommunityRulesUrl()) else { return }
        router.showSafari(for: u)
    }

    func rateUs() {
        SKStoreReviewController.requestReview()
    }

    func dismiss() {
        router.dismiss()
    }
}
