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
    init(owner: RoomDetailsViewController, room: Chat.Room) {
        self.owner = owner

        owner.children.forEach { childViewController in
            if let controller = childViewController as? ChatViewController {
                let router = ChatRouter(owner: controller)
                controller.viewModel = ChatViewModel(router: router, room: room)
            }
            if let controller = childViewController as? CommonFantasiesViewController {
                let router = CommonFantasiesRouter(owner: controller)
                controller.viewModel = CommonFantasiesViewModel(router: router, room: room)
            }
        }
    }
}
