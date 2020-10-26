//
//  WelcomeViewModel.swift
//  FantasyApp
//
//  Created by Anatoliy Afanasev on 10/11/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa

extension WelcomeViewModel {

    var termsUrl: String {
        return R.string.localizable.fantasyConstantsTermsUrl()
    }

    var privacyUrl: String {
        return R.string.localizable.fantasyConstantsPrivacyUrl()
    }

    var communityRulesUrl: String {
        return R.string.localizable.fantasyConstantsCommunityRulesUrl()
    }
}

class WelcomeViewModel : MVVM_ViewModel {

    /** Reference dependent viewModels, managers, stores, tracking variables...

     fileprivate let privateDependency = Dependency()

     fileprivate let privateTextVar = BehaviourRelay<String?>(nil)

     */
    
    init(router: WelcomeRouterRouter) {
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

    let router: WelcomeRouterRouter
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()

}

extension WelcomeViewModel {

    func presentSignIn() {
        router.presentSignIn()
    }

    func presentRegister() {
        router.presentRegister()
    }

    func authorizeUsingFacebook() {

        var timer = TimeSpentCounter()
        timer.start()
        
        AuthenticationManager.loginWithFacebook()
            .trackView(viewIndicator: indicator)
            .silentCatch(handler: router.owner)
            .subscribe(onNext: { (user) in
                Dispatcher.dispatch(action: SetUser(user: user))
            })
            .disposed(by: bag)

        Analytics.report(Analytics.Event.SignUpPassed.started(from: .Facebook))
    }

}
