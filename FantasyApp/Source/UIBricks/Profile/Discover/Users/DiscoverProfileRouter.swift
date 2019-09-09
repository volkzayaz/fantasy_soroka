//
//  DiscoverProfileRouter.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/9/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit
import RxCocoa

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
    
    func presentFilter(_ filter: BehaviorRelay<DiscoveryFilter?>) {
        
        let x = R.storyboard.user.discoveryFilterViewController()!
        x.viewModel = .init(router: .init(owner: x), filter: filter)
        owner.navigationController?.pushViewController(x, animated: true)
        
    }
    
}
