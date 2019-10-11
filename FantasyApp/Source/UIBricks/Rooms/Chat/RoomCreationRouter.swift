//
//  RoomCreationRouter.swift
//  FantasyApp
//
//  Created by Admin on 10.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

struct RoomCreationRouter: MVVM_Router {

    unowned private(set) var owner: RoomCreationViewController
    init(owner: RoomCreationViewController) {
        self.owner = owner
    }
}
