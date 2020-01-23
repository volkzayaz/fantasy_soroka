//
//  NewMessageInRoom.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 23.01.2020.
//  Copyright © 2020 Fantasy App. All rights reserved.
//

import Foundation

struct NewMessageSent: Action {
    
    let message: Room.MessageInRoom
    
    func perform(initialState: AppState) -> AppState {

        guard let i = initialState.rooms?.firstIndex(where: { $0.id == self.message.roomId }),
            var room = initialState.rooms?[i] else {
            fatalErrorInDebug("Can't update message in room that is not in the rooms list")
            return initialState
        }
        
        var state = initialState
        room.lastMessage = message.raw
        state.rooms?[i] = room
        return state
            
    }
    
}

struct MessageMakredRead: Action {
    
    let message: Room.MessageInRoom

    func perform(initialState: AppState) -> AppState {

        guard let i = initialState.rooms?.firstIndex(where: { $0.id == self.message.roomId }),
            var room = initialState.rooms?[i] else {
            fatalErrorInDebug("Can't update message in room that is not in the rooms list")
            return initialState
        }
        
        var state = initialState
        
        if room.unreadCount < 1 {
            fatalErrorInDebug("Internal inconsistency. \(room) has unread counter less then 1, it can't be decreased further")
            return initialState
        }
        
        room.unreadCount -= 1
        
        state.rooms?[i] = room
        return state
            
    }
    
}
