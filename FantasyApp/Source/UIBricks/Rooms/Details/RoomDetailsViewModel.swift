//
//  RoomDetailsViewModel.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 12.09.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct RoomDetailsViewModel: MVVM_ViewModel {
    enum DetailsPage: Int {
        case fantasies
        case chat
        case play
    }

    let router: RoomDetailsRouter
    let room: Room
    let page: BehaviorRelay<DetailsPage>

    init(router: RoomDetailsRouter,
         room: Room,
         page: DetailsPage) {
        self.router = router
        self.room = room
        self.page = BehaviorRelay(value: page)
    }
}

extension RoomDetailsViewModel {
    
    func showSettins() {
        router.showSettings()
    }
    
    func showPlay() {
        router.showPlay(room: room)
    }
    
}
