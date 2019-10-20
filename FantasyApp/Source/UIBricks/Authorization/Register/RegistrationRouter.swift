//
//  RegistrationRouter.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 7/27/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

struct RegistrationRouter : MVVM_Router {
    
    unowned private(set) var owner: UIViewController
    init(owner: UIViewController) {
        self.owner = owner
    }
    
    func dismiss() {
        owner.navigationController?.popViewController(animated: true)
    }
    
    func backToSignIn() {
        
        guard let vc = owner.navigationController?.viewControllers.first as? WelcomeViewController else {
            fatalErrorInDebug("Please reconsider your viewHierarchy. Registration Brick can't handle SignIn rout")
            return
        }

        let login = R.storyboard.authorization.loginViewController()!
        login.viewModel = .init(router: .init(owner: vc))

        owner.navigationController?.setViewControllers([vc, login], animated: true)
    }
    
}
