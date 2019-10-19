//
//  AddRoomNotificationSettings.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 19.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

struct AddRoomNotificationSettings: Action {
    let settings: RoomNotificationSettings

    func perform(initialState: AppState) -> AppState {
        var state = initialState
        if state.currentUser?.roomsNotificationSettings == nil {
            state.currentUser?.roomsNotificationSettings = [settings]
        } else {
            state.currentUser?.roomsNotificationSettings?.append(settings)
        }
        return state
    }

}



