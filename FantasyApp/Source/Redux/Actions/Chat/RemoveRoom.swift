//
//  RemoveRoom.swift
//  FantasyApp
//
//  Created by Admin on 10.09.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

struct RemoveRoom: Action {

    let room: Chat.Room

    func perform(initialState: AppState) -> AppState {
        var state = initialState
        state.currentUser?.connections.rooms.removeAll(where: { $0.objectId == room.objectId })
        return state
    }

}
