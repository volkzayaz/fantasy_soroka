//
//  MainTabBarRouter.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 7/27/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

struct MainTabBarRouter : MVVM_Router {
    
    unowned private(set) var owner: UITabBarController
    init(owner: UITabBarController) {
        self.owner = owner
    }
    
    func presentRoomSettings(room: Room) {
        
        owner.selectedIndex = 2
        let notificationController = (owner.viewControllers![2] as! UINavigationController).viewControllers.first! as! ConnectionViewController
        notificationController.viewModel.router.show(room: room, page: .chat)
        
    }
    
}
