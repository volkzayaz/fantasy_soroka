//
//  OnboardingRouter.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 7/11/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

struct OnboardingRouter: MVVM_Router {
    
    unowned private(set) var owner: UIViewController
    init(owner: UIViewController) {
        self.owner = owner
    }
    
    /**
     
     func showNextModule(with data: String) {
     
        let nextViewController = owner.storyboard.instantiate()
        let nextRouter = NextRouter(owner: nextViewController)
        let nextViewModel = NextViewModel(router: nextRuter, data: data)
        
        nextViewController.viewModel = nextViewModel
        owner.present(nextViewController)
     }
     
     */
    
}
