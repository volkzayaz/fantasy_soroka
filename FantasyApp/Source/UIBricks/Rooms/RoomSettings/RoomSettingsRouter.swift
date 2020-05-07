//
//  RoomSettingsRouter.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 10.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

struct RoomSettingsRouter: MVVM_Router {

    unowned private(set) var owner: RoomSettingsViewController
    init(owner: RoomSettingsViewController) {
        self.owner = owner
    }

    func showNotificationSettings(for room: Room) {
        let vc = R.storyboard.rooms.roomNotificationSettingsViewController()!
        vc.viewModel = .init(router: .init(owner: vc),
                             room: room)
        owner.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showUser(user: User?) {
        
        guard let user = unwrap(maybeUser: user, for: owner) else { return }
        
        let vc = R.storyboard.user.userProfileViewController()!
        vc.viewModel = .init(router: .init(owner: vc), user: user, bottomActionsAvailable: false)
        let navigationController = FantasyNavigationController(rootViewController: vc)
        navigationController.modalPresentationStyle = .overFullScreen
        owner.navigationController?.present(navigationController, animated: true, completion: nil)
        
    }
    
    func showSubscription() {
        
        let nav = R.storyboard.subscription.instantiateInitialViewController()!
        nav.modalPresentationStyle = .overFullScreen
        let vc = nav.viewControllers.first! as! SubscriptionViewController
        vc.viewModel = SubscriptionViewModel(router: .init(owner: vc), page: .member)
        
        owner.present(nav, animated: true, completion: nil)
        
    }
}
