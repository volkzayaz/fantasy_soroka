//
//  RemoveRoom.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 10.09.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

struct RemoveRoom: Action {

    let room: Chat.Room

    func perform(initialState: AppState) -> AppState {
        var state = initialState
        state.rooms.removeAll(where: { $0.id == room.id })
        return state
    }

}
