//
//  UserProfileRouter.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/5/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

struct UserProfileRouter : MVVM_Router {
    
    unowned private(set) var owner: UserProfileViewController
    init(owner: UserProfileViewController) {
        self.owner = owner
    }
    
    func present(room: Room) {
        let vc = R.storyboard.rooms.roomDetailsViewController()!
        vc.viewModel = RoomDetailsViewModel(router: .init(owner: vc),
                                            room: room,
                                            page: .chat)
        
        let container = FantasyNavigationController(rootViewController: vc)
        container.modalPresentationStyle = .overFullScreen
        
        owner.present(container, animated: true, completion: nil)
        
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
