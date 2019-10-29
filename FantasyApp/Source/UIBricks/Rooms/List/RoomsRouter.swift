//
//  RoomsRouter.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 10.09.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

struct RoomsRouter: MVVM_Router {

    unowned private(set) var owner: RoomsViewController
    init(owner: RoomsViewController) {
        self.owner = owner
    }

    func roomTapped(_ room: Room) {
        let vc = R.storyboard.chat.roomDetailsViewController()!
        vc.viewModel = .init(router: .init(owner: vc, room: room),
                             room: room,
                             page: .chat)
        owner.navigationController?.pushViewController(vc, animated: true)
    }

    func showRoomSettings(_ room: Room) {
        let vc = R.storyboard.chat.roomDetailsViewController()!
        vc.viewModel = .init(router: .init(owner: vc, room: room),
                             room: room,
                             page: .chat)
        owner.navigationController?.pushViewController(vc, animated: true)
        vc.viewModel.showSettins()
    }

    func close() {
        owner.navigationController?.popViewController(animated: true)
    }
}
