//
//  RoomsRouter.swift
//  FantasyApp
//
//  Created by Admin on 10.09.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

struct RoomsRouter : MVVM_Router {

    unowned private(set) var owner: RoomsViewController
    init(owner: RoomsViewController) {
        self.owner = owner
    }

    func roomTapped(_ room: Chat.Room) {
        let vc = R.storyboard.chat.roomDetailsViewController()!
        vc.viewModel = .init(router: .init(owner: vc),
                             room: room,
                             page: .chat)
        owner.navigationController?.pushViewController(vc, animated: true)
    }
}
