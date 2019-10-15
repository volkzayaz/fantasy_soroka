//
//  RoomSettingsRouter.swift
//  FantasyApp
//
//  Created by Admin on 10.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

struct RoomSettingsRouter: MVVM_Router {

    unowned private(set) var owner: RoomSettingsViewController
    init(owner: RoomSettingsViewController) {
        self.owner = owner
    }
}
