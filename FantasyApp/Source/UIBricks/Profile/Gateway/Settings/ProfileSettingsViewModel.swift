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

        appState.changesOf { $0.currentUser?.bio.name }
        .drive(usernameVar)
        .disposed(by: bag)
    }
    
    let router: ProfileSettingsRouter
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
    fileprivate let usernameVar = BehaviorRelay<String?>(value: nil)
}

extension ProfileSettingsViewModel {
    
    func logout() {

        let actions: [UIAlertAction] = [
            .init(title: R.string.localizable.generalNo(), style: .cancel, handler: nil),
            .init(title: R.string.localizable.fantasySettingsLogoutAlertAction(), style: .destructive, handler: { _ in
                AuthenticationManager.logout()
                Dispatcher.dispatch(action: Logout())
                self.router.dismiss()
            })
        ]

        router.owner.showDialog(title: R.string.localizable.fantasySettingsLogoutAlertTitle(), text: R.string.localizable.fantasySettingsLogoutAlertText(), style: .alert, actions: actions)
    }
    
    func deleteAccount() {

        let actions: [UIAlertAction] = [
            .init(title: R.string.localizable.generalCancel(), style: .cancel, handler: nil),
            .init(title:  R.string.localizable.fantasySettingsDeleteAccountAlertAction(), style: .destructive, handler: { _ in
                let _ = UserManager.deleteAccount()
                                   .trackView(viewIndicator: self.indicator)
                                   .silentCatch(handler: self.router.owner)
                                   .subscribe(onNext: self.logout)
            })
        ]

         router.owner.showDialog(title: R.string.localizable.fantasySettingsDeleteAccountAlertTitle(), text: R.string.localizable.fantasySettingsDeleteAccountAlertText(), style: .actionSheet, actions: actions)
    }

    func restorePurchases() {
        PurchaseManager.restorePurchases()
            .trackView(viewIndicator: indicator)
            .silentCatch(handler: router.owner)
            .subscribe()
            .disposed(by: bag)
    }

    func helpSupport() {
        router.showSupport(for: usernameVar.value ?? R.string.localizable.fantasySettingsSectionSupportUnknownUser(),
                           email: PFUser.current()?.email)
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
