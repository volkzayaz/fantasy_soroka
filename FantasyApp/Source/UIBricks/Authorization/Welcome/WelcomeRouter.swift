//
//  WelcomeRouter.swift
//  FantasyApp
//
//  Created by Anatoliy Afanasev on 10/11/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

struct WelcomeRouterRouter : MVVM_Router {
    
    unowned private(set) var owner: UIViewController
    init(owner: UIViewController) {
        self.owner = owner
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            Analytics.report(Analytics.Event.FirstScreen())
        }
        
    }

    func presentRegister() {

        let vc = R.storyboard.authorization.registrationViewController()!
        vc.viewModel = .init(router: .init(owner: vc))

        owner.navigationController?.pushViewController(vc, animated: true)
        
        Analytics.report(Analytics.Event.SignUpPassed.started(from: .Email))
    }

    func presentSignIn() {
        let vc = R.storyboard.authorization.loginViewController()!
        vc.viewModel = .init(router: .init(owner: vc), context: .FirstScreen)

        owner.navigationController?.pushViewController(vc, animated: true)
    }
    
}
