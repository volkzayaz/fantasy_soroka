//
//  FantasyDeckRouter.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 8/14/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

struct FantasyDeckRouter : MVVM_Router {
    
    unowned private(set) var owner: FantasyDeckViewController
    init(owner: FantasyDeckViewController) {
        self.owner = owner
    }
    
    func cardTapped(provider: FantasyDetailProvider) {
        
        let vc = R.storyboard.fantasyCard.fantasyDetailsViewController()!
        vc.viewModel = .init(router: .init(owner: vc), provider: provider)
        vc.modalPresentationStyle = .overFullScreen
        vc.transitioningDelegate = owner
        
        owner.navigationController?.present(vc, animated: true, completion: nil)
        
    }
    
    func show(collection: Fantasy.Collection) {
        
        let vc = R.storyboard.fantasyCard.fantasyCollectionDetailsViewController()!
        vc.viewModel = .init(router: .init(owner: vc), collection: collection)
        let container = FantasyNavigationController(rootViewController: vc)
        container.modalPresentationStyle = .overFullScreen
        
        owner.present(container, animated: true, completion: nil)
        
    }
    
}
