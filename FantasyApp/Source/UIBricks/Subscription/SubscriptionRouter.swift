//
//  SubscriptionRouter.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 10.01.2020.
//Copyright © 2020 Fantasy App. All rights reserved.
//

import UIKit

struct SubscriptionRouter : MVVM_Router {
    
    unowned let owner: SubscriptionViewController
    init(owner: SubscriptionViewController) {
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
