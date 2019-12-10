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

struct ProfileSettingsViewModel : MVVM_ViewModel {

    init(router: ProfileSettingsRouter) {
        self.router = router
        
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
    
    private func logoutActions() {
        AuthenticationManager.logout()
        Dispatcher.dispatch(action: Logout())
        self.router.dismiss()
    }
    
    func logout() {

        let actions: [UIAlertAction] = [
            .init(title: R.string.localizable.generalNo(), style: .cancel, handler: nil),
            .init(title: R.string.localizable.fantasySettingsLogoutAlertAction(), style: .destructive, handler: { _ in
                self.logoutActions()
            })
        ]

        router.owner.showDialog(title: R.string.localizable.fantasySettingsLogoutAlertTitle(), text: R.string.localizable.fantasySettingsLogoutAlertText(), style: .alert, actions: actions)
        
        Analytics.report(Analytics.Event.ProfileLogout())
    }
    
    func deleteAccount() {

        let actions: [UIAlertAction] = [
            .init(title: R.string.localizable.generalCancel(), style: .cancel, handler: nil),
            .init(title:  R.string.localizable.fantasySettingsDeleteAccountAlertAction(), style: .destructive, handler: { _ in
                let _ = UserManager.deleteAccount()
                                   .trackView(viewIndicator: self.indicator)
                                   .silentCatch(handler: self.router.owner)
                                   .subscribe(onNext: self.logoutActions)
            })
        ]

         router.owner.showDialog(title: R.string.localizable.fantasySettingsDeleteAccountAlertTitle(), text: R.string.localizable.fantasySettingsDeleteAccountAlertText(), style: .actionSheet, actions: actions)
        
        Analytics.report(Analytics.Event.ProfileDelete())
    }

    func restorePurchases() {
        PurchaseManager.restorePurchases()
            .trackView(viewIndicator: indicator)
            .silentCatch(handler: router.owner)
            .subscribe()
            .disposed(by: bag)
    }

    func helpSupport() {
        guard let u = User.current  else { return }
        router.showSupport(for: u.bio.name, email: PFUser.current()?.email)
    }

    func termsAndConditions() {
        guard let u = URL(string: R.string.localizable.fantasyConstantsTermsUrl()) else { return }
        router.showSafari(for: u)
    }
    
    func privacyPolicy() {
        guard let u = URL(string: R.string.localizable.fantasyConstantsPrivacyUrl()) else { return }
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
