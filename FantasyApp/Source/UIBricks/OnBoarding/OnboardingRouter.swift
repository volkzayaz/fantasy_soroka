//
//  OnboardingRouter.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 7/11/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

struct OnboardingRouter : MVVM_Router {
    
    var owner: UIViewController {
        return _owner!
    }
    
    weak private var _owner: OnboardingRouter.T?
    init(owner: OnboardingRouter.T) {
        self._owner = owner
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
