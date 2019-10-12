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
    
    /** Reference binding drivers that are going to be used in the corresponding view

     var text: Driver<String> {
     return privateTextVar.asDriver().notNil()
     }

     */
    
}

struct ForgotPasswordViewModel : MVVM_ViewModel {

    init(router: ForgotPasswordRouter) {
        self.router = router

        /////progress indicator

        indicator.asDriver()
            .drive(onNext: { [weak h = router.owner] (loading) in
                h?.setLoadingStatus(loading)
            })
            .disposed(by: bag)
    }
    
    let router: ForgotPasswordRouter
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
}

extension ForgotPasswordViewModel {

    func closeSignIn() {
        router.closeSignIn()
    }

    func resetPassword(_ email: String) {

        PFUser.requestPasswordResetForEmail(inBackground: email) { (res, error) in

            if let e = error {
                self.router.owner.present(error: e)
            }
            else {
                self.router.owner.showMessage(title: "Success",
                                              text: "Check your email for instructions")
            }

        }
    }

}
