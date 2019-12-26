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
    let room: Room

    var currentSettings: Room.Settings.Notifications {
        return room.settings.notifications
    }

    init(router: RoomNotificationSettingsRouter, room: Room) {
        self.router = router
        self.room = room
    }
}

extension RoomNotificationSettingsViewModel {
    
    func changeMessageSettings(state: Bool) {
        
        var r = room
        r.settings.notifications.newMessage = state
        
        Dispatcher.dispatch(action: UpdateRoomSettingsIn(room: r))
        
    }

    func changeCommonFantasySettings(state: Bool) {
        
        var r = room
        r.settings.notifications.newFantasyMatch = state
        
        Dispatcher.dispatch(action: UpdateRoomSettingsIn(room: r))
        
    }

}
