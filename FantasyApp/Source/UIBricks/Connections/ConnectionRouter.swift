//
//  ConnectionRouter.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/20/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

struct ConnectionRouter : MVVM_Router {
    
    unowned private(set) var owner: ConnectionViewController
    init(owner: ConnectionViewController) {
        self.owner = owner
    }
    
    func show(user: User) {
        
        let x = R.storyboard.user.userProfileViewController()!
        x.viewModel = .init(router: .init(owner: x), user: user)
        owner.navigationController?.pushViewController(x, animated: true)
        
    }
}
