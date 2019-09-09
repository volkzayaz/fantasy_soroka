//
//  DiscoverProfileRouter.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/9/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

struct DiscoverProfileRouter : MVVM_Router {
    
    unowned private(set) var owner: DiscoverProfileViewController
    init(owner: DiscoverProfileViewController) {
        self.owner = owner
    }
    
    func presentProfile(_ profile: Profile) {
    
        let x = R.storyboard.user.userProfileViewController()!
        x.viewModel = .init(router: .init(owner: x), user: profile)
        owner.navigationController?.pushViewController(x, animated: true)
        
    }
    
}
