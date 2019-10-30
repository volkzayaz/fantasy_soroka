//
//  FantasyCollectionRouter.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 8/21/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

struct FantasyCollectionRouter : MVVM_Router {
    
    unowned private(set) var owner: FantasyCollectionViewController
    init(owner: FantasyCollectionViewController) {
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
