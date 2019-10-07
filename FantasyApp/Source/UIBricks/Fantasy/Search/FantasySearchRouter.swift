//
//  FantasySearchRouter.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 8/18/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

struct FantasySearchRouter : MVVM_Router {
    
    unowned private(set) var owner: FantasySearchViewController
    init(owner: FantasySearchViewController) {
        self.owner = owner
    }

    func cardTapped(card: Fantasy.Card) {
        
        let vc = R.storyboard.fantasyCard.fantasyDetailsViewController()!
        vc.viewModel = .init(router: .init(owner: vc), card: card, shouldDecrement: true)
        owner.navigationController?.pushViewController(vc, animated: true)
        
    }
    
}