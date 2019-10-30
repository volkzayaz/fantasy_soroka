//
//  RoomDetailsRouter.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 12.09.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

struct RoomDetailsRouter: MVVM_Router {

    unowned private(set) var owner: RoomDetailsViewController
    private var room: Room
    init(owner: RoomDetailsViewController, room: Room) {
        self.owner = owner
        self.room = room
    }

    func showSettings() {
        
        let viewController = R.storyboard.chat.roomSettingsViewController()!
        let router = RoomSettingsRouter(owner: viewController)
        viewController.viewModel = RoomSettingsViewModel(router: router, room: room)
        owner.present(viewController, animated: true, completion: nil)
        
    }
    
    func showPlay(room: Room) {
        
        let vc = R.storyboard.fantasyCard.fantasiesViewController()!
        vc.viewModel = FantasyDeckViewModel(router: .init(owner: vc),
                                            provider: RoomsDeckProvider(room: room))
        
        owner.navigationController?.pushViewController(vc, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            vc.collectionsButton.isHidden = true
            vc.cardsButton.isHidden = true
            vc.title = "Fantasies with \(room.peer.userSlice.name)"
        }
        
    }

    func embedChat(in view: UIView) {
        let viewController = ChatViewController()
        let router = ChatRouter(owner: viewController)
        viewController.viewModel = ChatViewModel(router: router, room: room, chattoDelegate: viewController)
        viewController.view.frame = view.bounds
        view.addSubview(viewController.view)
        owner.addChild(viewController)
        viewController.didMove(toParent: owner)
    }
    
}
