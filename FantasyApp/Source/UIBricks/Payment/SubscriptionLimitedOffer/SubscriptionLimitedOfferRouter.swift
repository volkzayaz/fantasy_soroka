//
//  SubscriptionLimitedOfferRouter.swift
//  FantasyApp
//
//  Created by Vodolazkyi Anton on 12.07.2020.
//  Copyright © 2020 Fantasy App. All rights reserved.
//

import UIKit

struct SubscriptionLimitedOfferRouter: MVVM_Router {
    
    unowned let owner: SubscriptionLimitedOfferController
    init(owner: SubscriptionLimitedOfferController) {
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
