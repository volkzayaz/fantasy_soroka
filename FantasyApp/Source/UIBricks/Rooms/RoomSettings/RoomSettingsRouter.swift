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
        let vc = R.storyboard.chat.roomNotificationSettingsViewController()!
        vc.viewModel = .init(router: .init(owner: vc),
                             room: room)
        owner.navigationController?.pushViewController(vc, animated: true)
    }
}
