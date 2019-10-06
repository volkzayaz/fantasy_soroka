//
//  MyFantasiesReactionHistoryRouter.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 10/6/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

struct MyFantasiesReactionHistoryRouter : MVVM_Router {
    
    unowned private(set) var owner: MyFantasiesReactionHistoryViewController
    init(owner: MyFantasiesReactionHistoryViewController) {
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
