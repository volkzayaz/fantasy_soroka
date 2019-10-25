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
    
    func searchTapped() {
        
        let vc = R.storyboard.fantasyCard.fantasySearchViewController()!
        vc.viewModel = .init(router: .init(owner: vc))
        owner.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func cardTapped(card: Fantasy.Card) {
        
        let vc = R.storyboard.fantasyCard.fantasyDetailsViewController()!
        vc.viewModel = .init(router: .init(owner: vc), card: card, shouldDecrement: true)
        vc.modalPresentationStyle = .overFullScreen
        vc.transitioningDelegate = owner
        owner.navigationController?.present(vc, animated: true, completion: nil)
        
    }
}
