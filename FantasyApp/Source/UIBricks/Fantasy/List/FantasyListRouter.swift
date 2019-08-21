//
//  FantasyListRouter.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 8/18/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

struct FantasyListRouter : MVVM_Router {
    
    unowned private(set) var owner: FantasyListViewController
    init(owner: FantasyListViewController) {
        self.owner = owner
    }
    
    func cardTapped(card: Fantasy.Card) {
        
        let vc = R.storyboard.fantasyCard.fantasyDetailsViewController()!
        vc.viewModel = .init(router: .init(owner: vc), card: card, shouldDecrement: false)
        owner.navigationController?.pushViewController(vc, animated: true)
        
    }
    
}
