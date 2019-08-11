//
//  LoginRouter.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 7/27/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

struct LoginRouter : MVVM_Router {

    unowned private(set) var owner: UIViewController
    init(owner: UIViewController) {
        self.owner = owner
    }
    
    func presentRegister() {
        let vc = R.storyboard.authorization.registrationViewController()!
        vc.viewModel = .init(router: .init(owner: vc))
        
        owner.navigationController?.pushViewController(vc, animated: true)
    }
    
}
