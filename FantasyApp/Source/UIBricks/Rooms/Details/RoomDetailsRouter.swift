//
//  RoomDetailsRouter.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 12.09.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

struct RoomDetailsRouter: MVVM_Router {

    unowned private(set) var owner: RoomDetailsViewController
    private var room: Room
    init(owner: RoomDetailsViewController, room: Room) {
        self.owner = owner
        self.room = room
    }

    func embedSettings(in view: UIView) {
        let viewController = R.storyboard.chat.roomSettingsViewController()!
        let router = RoomSettingsRouter(owner: viewController)
        viewController.viewModel = RoomSettingsViewModel(router: router, room: room)
        viewController.view.frame = view.bounds
        view.addSubview(viewController.view)
        owner.addChild(viewController)
        viewController.didMove(toParent: owner)
    }

    func embedChat(in view: UIView) {
        let viewController = ChatViewController()
        let router = ChatRouter(owner: viewController)
        viewController.viewModel = ChatViewModel(router: router, room: room)
        viewController.view.frame = view.bounds
        view.addSubview(viewController.view)
        owner.addChild(viewController)
        viewController.didMove(toParent: owner)
    }

    func embedCommonFantasies(in view: UIView) {
        let viewController = R.storyboard.chat.commonFantasiesViewController()!
        let router = CommonFantasiesRouter(owner: viewController)
        viewController.viewModel = CommonFantasiesViewModel(router: router, room: room)
        viewController.view.frame = view.bounds
        view.addSubview(viewController.view)
        owner.addChild(viewController)
        viewController.didMove(toParent: owner)
    }

    func embedPlay(in view: UIView) {

    }
}
