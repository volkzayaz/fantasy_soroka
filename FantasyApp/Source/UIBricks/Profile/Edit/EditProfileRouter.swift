//
//  EditProfileRouter.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/2/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

struct EditProfileRouter : MVVM_Router {
    
    unowned private(set) var owner: EditProfileViewController
    init(owner: EditProfileViewController) {
        self.owner = owner
    }
    
    func preview(user: User) {
        
        let x = R.storyboard.user.userProfileViewController()!
        x.viewModel = .init(router: .init(owner: x), user: user)
        owner.navigationController?.pushViewController(x, animated: true)
        
    }
    
    /**
     
     func showNextModule(with data: String) {
     
        let nextViewController = owner.storyboard.instantiate()
        let nextRouter = NextRouter(owner: nextViewController)
        let nextViewModel = NextViewModel(router: nextRuter, data: data)
        
        nextViewController.viewModel = nextViewModel
        owner.present(nextViewController)
     }
     
     */
    
}
