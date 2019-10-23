//
//  AddRooms.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 10.09.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

struct SetRooms: Action {

    let rooms: [Room]

    func perform(initialState: AppState) -> AppState {
        var state = initialState
        state.rooms = rooms
        state.reloadRoomsTriggerBecauseOfComplexFreezeLogic = false
        return state
    }
}

struct TriggerRoomsRefresh: Action {
    
    func perform(initialState: AppState) -> AppState {
        var state = initialState
        state.reloadRoomsTriggerBecauseOfComplexFreezeLogic = true
        return state
    }
    
}
