//
//  NotificationSettingsRouter.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 10/9/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

struct NotificationSettingsRouter : MVVM_Router {
    
    unowned private(set) var owner: NotificationSettingsViewController
    init(owner: NotificationSettingsViewController) {
        self.owner = owner
    }
}
