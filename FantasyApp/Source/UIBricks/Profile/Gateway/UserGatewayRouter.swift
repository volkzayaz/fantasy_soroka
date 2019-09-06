//
//  UserGatewayRouter.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 7/27/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

struct UserGatewayRouter : MVVM_Router {
    
    unowned private(set) var owner: UIViewController
    init(owner: UIViewController) {
        self.owner = owner
    }
    
    func showCards(cards: [Fantasy.Card]) {
        
        let vc = R.storyboard.fantasyCard.fantasyListViewController()!
        vc.viewModel = .init(router: .init(owner: vc), cards: cards)
        owner.navigationController?.pushViewController(vc, animated: true)
        
    }

    func showEditProfile() {
        
        let vc = R.storyboard.user.editProfileViewController()!
        vc.viewModel = .init(router: .init(owner: vc))

        owner.navigationController?.pushViewController(vc, animated: true)
        
    }
    
}
