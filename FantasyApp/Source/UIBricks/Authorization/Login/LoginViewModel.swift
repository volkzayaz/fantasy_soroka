//
//  LoginViewModel.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 7/27/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa

extension LoginViewModel {

    var signinButtonEnabled: Driver<Bool> {
        return Driver.combineLatest(emailVar.asDriver(), passwordVar.asDriver()) { ($0, $1) }
            .map { (tuple) -> Bool in
                return tuple.0.isValidEmail && tuple.1.count > 0
        }
    }
}

class LoginViewModel : MVVM_ViewModel {

    fileprivate let emailVar = BehaviorRelay(value: "")
    fileprivate let passwordVar = BehaviorRelay(value: "")
    fileprivate let bag = DisposeBag()
    private let context: Analytics.Event.SignIn.Source
    
    init(router: LoginRouter, context: Analytics.Event.SignIn.Source) {
        self.router = router
        self.context = context
        
        /////progress indicator
        
        indicator.asDriver()
            .drive(onNext: { [weak h = router.owner] (loading) in
                h?.setLoadingStatus(loading)
            })
            .disposed(by: bag)
    }
    
    let router: LoginRouter
    fileprivate let indicator: ViewIndicator = ViewIndicator()
}

extension LoginViewModel {

    func emailChanged(email: String) {
        emailVar.accept(email)
    }

    func passwordChanged(password: String) {
        passwordVar.accept(password)
    }

    func presentForgotPassword() {
        router.presentForgotPassword()
    }

    func presentRegister() {
        router.presentRegister()
    }
    
    func login(email: String, password: String) {
        
        AuthenticationManager.login(with: email, password: password)
            .trackView(viewIndicator: indicator)
            .silentCatch(handler: router.owner)
            .subscribe(onNext: { (user) in
                Dispatcher.dispatch(action: SetUser(user: user))
                
                Analytics.report(Analytics.Event.SignIn(source: self.context, isSuccess: true))
            }, onError: { error in
                Analytics.report(Analytics.Event.SignIn(source: self.context, isSuccess: false))
            })
            .disposed(by: bag)
        
    }

    func closeSignIn() {
        router.closeSignIn()
    }
}
