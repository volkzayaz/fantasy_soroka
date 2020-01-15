//
//  RoomsRouter.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 10.09.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

struct RoomsRouter: MVVM_Router {

    unowned private(set) var owner: RoomsViewController
    init(owner: RoomsViewController) {
        self.owner = owner
    }

    func roomTapped(_ room: Room) {
        let vc = R.storyboard.rooms.roomDetailsViewController()!
        vc.viewModel = .init(router: .init(owner: vc),
                             room: room,
                             page: .chat)
        
//        let vc = ChatViewController(tableViewStyle: .plain)!
//        vc.viewModel = ChatViewModel(router: .init(owner: vc), room: SharedRoomResource(value: room))
        
        owner.navigationController?.pushViewController(vc, animated: true)
    }

    func showRoomSettings(_ room: Room) {
        
        let vc = R.storyboard.rooms.roomSettingsViewController()!
        vc.viewModel = .init(router: .init(owner: vc), room: SharedRoomResource(value: room))
        
        let container = FantasyNavigationController(rootViewController: vc)
        owner.present(container, animated: true, completion: nil)
        
    }

    func close() {
        owner.navigationController?.popViewController(animated: true)
    }
    
    func showSubscription() {
        
        let nav = R.storyboard.subscription.instantiateInitialViewController()!
        nav.modalPresentationStyle = .overFullScreen
        let vc = nav.viewControllers.first! as! SubscriptionViewController
        vc.viewModel = SubscriptionViewModel(router: .init(owner: vc), page: .screenProtect)
        
        owner.present(nav, animated: true, completion: nil)
        
    }
}
