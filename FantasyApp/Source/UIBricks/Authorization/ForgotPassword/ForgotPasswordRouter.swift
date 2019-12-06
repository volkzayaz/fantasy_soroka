//
//  ForgotPasswordRouter.swift
//  FantasyApp
//
//  Created by Anatoliy Afanasev on 10/12/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

struct ForgotPasswordRouter: MVVM_Router {
    
    unowned private(set) var owner: UIViewController
    init(owner: UIViewController) {
        self.owner = owner
    }

    func closeSignIn() {
        owner.navigationController?.popViewController(animated: true)
    }
}
