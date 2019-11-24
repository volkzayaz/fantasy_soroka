//
//  RoomDetailsRouter.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 12.09.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

struct RoomDetailsRouter: MVVM_Router {

    unowned let owner: RoomDetailsViewController
    
    init(owner: RoomDetailsViewController) {
        self.owner = owner
    }

    func showSettings(room: SharedRoomResource) {
        
        let viewController = R.storyboard.rooms.roomSettingsViewController()!
        let router = RoomSettingsRouter(owner: viewController)
        viewController.viewModel = RoomSettingsViewModel(router: router, room: room)
        
        let container = FantasyNavigationController(rootViewController: viewController)
        container.modalPresentationStyle = .overFullScreen
        
        owner.present(container, animated: true, completion: nil)
        
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

}
