//
//  AddRooms.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 10.09.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

struct SetRooms: Action {

    let rooms: [Chat.Room]

    func perform(initialState: AppState) -> AppState {
        var state = initialState
        state.rooms = rooms
        return state
    }
}
