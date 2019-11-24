//
//  MyFantasiesSettingsRouter.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 10/6/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

struct MyFantasiesSettingsRouter : MVVM_Router {
    
    unowned private(set) var owner: MyFantasiesSettingsViewController
    init(owner: MyFantasiesSettingsViewController) {
        self.owner = owner
    }
}
