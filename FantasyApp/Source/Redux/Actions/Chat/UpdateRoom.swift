//
//  UpdateRoom.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 10.09.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

struct UpdateRoom: Action {

    let room: Room

    func perform(initialState: AppState) -> AppState {
        var state = initialState
        if let index = state.rooms.firstIndex(where: { $0.id == room.id }) {
            state.rooms[index] = room
        }

        return state
    }

}
