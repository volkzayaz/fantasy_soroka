//
//  DiscoveryFilterRouter.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/9/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

struct DiscoveryFilterRouter : MVVM_Router {
    
    unowned private(set) var owner: DiscoveryFilterViewController
    init(owner: DiscoveryFilterViewController) {
        self.owner = owner
    }
    
    func openTeleport() {
        let x = R.storyboard.user.teleportViewController()!
        x.viewModel = .init(router: .init(owner: x), response: .directApplication)
        owner.navigationController?.pushViewController(x, animated: true)
    }

    func cancel() {
        owner.navigationController?.dismiss(animated: true, completion: nil)
    }
}
