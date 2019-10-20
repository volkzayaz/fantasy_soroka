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
    
    func presentTeleport() {
        
        let x = R.storyboard.user.teleportViewController()!
        x.viewModel = .init(router: .init(owner: x), response: .directApplication)
        owner.navigationController?.pushViewController(x, animated: true)
        
    }
    
}
