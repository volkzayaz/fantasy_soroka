//
//  MyFantasiesRouter.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/29/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

struct MyFantasiesRouter : MVVM_Router {
    
    unowned private(set) var owner: MyFantasiesViewController
    init(owner: MyFantasiesViewController) {
        self.owner = owner
    }
    
    func showCards(cards: [Fantasy.Card]) {
        
        let vc = R.storyboard.fantasyCard.fantasyListViewController()!
        vc.viewModel = .init(router: .init(owner: vc), cards: cards)
        owner.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
}
