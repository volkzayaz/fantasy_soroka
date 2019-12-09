//
//  ForgotPasswordViewModel.swift
//  FantasyApp
//
//  Created by Anatoliy Afanasev on 10/12/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa

extension ForgotPasswordViewModel {
    
    var resetButtonEnabled: Driver<Bool> {
        return emailVar.asDriver()
            .map { (email) -> Bool in
                return email.isValidEmail
        }
    }

    var loading: Driver<Bool> {
        return indicator.asDriver()
    }

    var showCodeWasSent: Driver<Bool> {
        return showCodeWasSentVar.asDriver()
    }

    var showWrongEmail: Driver<Bool> {
        return showWrongEmailVar.asDriver()
    }
}

struct ForgotPasswordViewModel : MVVM_ViewModel {

    fileprivate let emailVar = BehaviorRelay(value: "")
    fileprivate let showCodeWasSentVar = BehaviorRelay(value: false)
    fileprivate let showWrongEmailVar = BehaviorRelay(value: false)

    init(router: ForgotPasswordRouter) {
        self.router = router
    }
    
    let router: ForgotPasswordRouter
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
}

extension ForgotPasswordViewModel {

    func emailChanged(email: String) {
        showWrongEmailVar.accept(false)
        emailVar.accept(email)
    }

    func closeSignIn() {
        router.closeSignIn()
    }

    func resetPassword(_ email: String) {

        AuthenticationManager.requestPassword(with: email)
            .trackView(viewIndicator: indicator)
            .subscribe(onNext: { (res) in
                guard res else { return }
                self.showCodeWasSentVar.accept(true)
                
                Analytics.report(Analytics.Event.ForgotPasswordSubmitted(isSuccessful: true))
            }, onError: { (e) in
                self.showWrongEmailVar.accept(true)
                
                Analytics.report(Analytics.Event.ForgotPasswordSubmitted(isSuccessful: false))
            })
            .disposed(by: bag)

    }

}
