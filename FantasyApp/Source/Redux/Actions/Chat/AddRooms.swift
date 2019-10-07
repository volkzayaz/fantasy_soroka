//
//  AddRooms.swift
//  FantasyApp
//
//  Created by Admin on 10.09.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

struct AddRooms: Action {

    let rooms: [Chat.RoomDetails]

    func perform(initialState: AppState) -> AppState {
        var state = initialState
        state.currentUser?.connections.rooms.append(contentsOf: rooms)
        return state
    }

}
