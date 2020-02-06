//
//  TeleportRouter.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/18/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

struct TeleportRouter : MVVM_Router {
    
    unowned let owner: TeleportViewController
    init(owner: TeleportViewController) {
        self.owner = owner
    }
    
    func popBack() {
        
        owner.navigationController?.popViewController(animated: true)
        
    }

    func showSubscription(completion: @escaping () -> Void) {
        
        let nav = R.storyboard.subscription.instantiateInitialViewController()!
        nav.modalPresentationStyle = .overFullScreen
        let vc = nav.viewControllers.first! as! SubscriptionViewController
        vc.viewModel = SubscriptionViewModel(router: .init(owner: vc), page: .teleport, completion: completion)
        
        owner.present(nav, animated: true, completion: nil)
        
    }
    
}
