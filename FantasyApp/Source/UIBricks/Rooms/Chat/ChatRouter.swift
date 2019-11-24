//
//  ChatRouter.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 12.09.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

struct ChatRouter: MVVM_Router {

    unowned private(set) var owner: ChatViewController
    init(owner: ChatViewController) {
        self.owner = owner
    }
    
    func showUser(user: User) {
        
        let vc = R.storyboard.user.userProfileViewController()!
        vc.viewModel = .init(router: .init(owner: vc), user: user, bottomActionsAvailable: false)
        owner.navigationController?.pushViewController(vc, animated: true)
        
    }
    
}
