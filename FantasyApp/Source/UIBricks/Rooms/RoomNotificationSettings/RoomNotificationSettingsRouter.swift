//
//  RoomNotificationSettingsRouter.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 19.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

struct RoomNotificationSettingsRouter: MVVM_Router {

    unowned private(set) var owner: RoomNotificationSettingsViewController
    init(owner: RoomNotificationSettingsViewController) {
        self.owner = owner
    }
}
