//
//  ConnectionRouter.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/20/19.
//Copyright © 2019 Fantasy App. All rights reserved.
//

import UIKit

struct ConnectionRouter : MVVM_Router {
    
    unowned private(set) var owner: ConnectionViewController
    init(owner: ConnectionViewController) {
        self.owner = owner
    }
    
    func show(room: Room) {
        let vc = R.storyboard.chat.roomDetailsViewController()!
        vc.viewModel = RoomDetailsViewModel(router: .init(owner: vc, room: room), room: room,
                                            page: .chat)
        owner.navigationController?.pushViewController(vc, animated: true)
        
    }
    
}
