//
//  UpdateRoom.swift
//  FantasyApp
//
//  Created by Admin on 10.09.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

struct UpdateRoom: Action {

    let room: Chat.RoomDetails

    func perform(initialState: AppState) -> AppState {
        var state = initialState
        if let index = state.currentUser?.connections.rooms
            .firstIndex(where: { $0.objectId == room.objectId }) {
            state.currentUser?.connections.rooms[index] = room
        }

        return state
    }

}
