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
    
    func present(room: Chat.Room) {
        let vc = R.storyboard.chat.roomDetailsViewController()!
        vc.viewModel = RoomDetailsViewModel(router: .init(owner: vc, room: room), room: room,
                                            page: .chat)
        owner.navigationController?.pushViewController(vc, animated: true)
        
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
