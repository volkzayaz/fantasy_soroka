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
        return "https://fantasyapp.com/en/terms-and-conditions/"
    }

    var privacyUrl: String {
        return "https://fantasyapp.com/en/privacy-policy/"
    }

    var communityRulesUrl: String {
        return "https://fantasyapp.com/en/community-rules/"
    }

}

struct WelcomeViewModel : MVVM_ViewModel {

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

        AuthenticationManager.loginWithFacebook()
            .trackView(viewIndicator: indicator)
            .silentCatch(handler: router.owner)
            .subscribe(onNext: { (user) in
                Dispatcher.dispatch(action: SetUser(user: user))
            })
            .disposed(by: bag)

    }

}
