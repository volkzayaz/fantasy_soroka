//
//  RoomDetailsRouter.swift
//  FantasyApp
//
//  Created by Admin on 12.09.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

struct RoomDetailsRouter: MVVM_Router {

    unowned private(set) var owner: RoomDetailsViewController
    init(owner: RoomDetailsViewController) {
        self.owner = owner
    }
}
