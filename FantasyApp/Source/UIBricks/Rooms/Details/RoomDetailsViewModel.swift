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
        case settings
        case fantasies
        case chat
        case play
    }

    let router: RoomDetailsRouter
    let room: Chat.Room
    let page: BehaviorRelay<DetailsPage>

    init(router: RoomDetailsRouter,
         room: Chat.Room,
         page: DetailsPage) {
        self.router = router
        self.room = room
        self.page = BehaviorRelay(value: page)
    }
}
