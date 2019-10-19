//
//  RoomNotificationSettingsViewModel.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 19.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct RoomNotificationSettingsViewModel: MVVM_ViewModel {
    let router: RoomNotificationSettingsRouter
    let room: BehaviorRelay<Chat.Room>

    var currentSettings: RoomNotificationSettings? {
        return appStateSlice.currentUser!.roomsNotificationSettings?.first(where: { $0.roomId == room.value.id })
    }

    init(router: RoomNotificationSettingsRouter, room: Chat.Room) {
        self.router = router
        self.room = BehaviorRelay(value: room)
    }
}

extension RoomNotificationSettingsViewModel {
    func changeMessageSettings(state: Bool) {
        Dispatcher.dispatch(action: UpdateRoomNotificationSettings(roomId: room.value.id,
                                                                   mapper: { $0.newMessage = state }))
    }

    func changeCommonFantasySettings(state: Bool) {
        Dispatcher.dispatch(action: UpdateRoomNotificationSettings(roomId: room.value.id,
                                                                   mapper: { $0.newFantasyMatch = state }))
    }

}
