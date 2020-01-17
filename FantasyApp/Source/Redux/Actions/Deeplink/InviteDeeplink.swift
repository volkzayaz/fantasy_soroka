//
//  InviteDeeplink.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 10/26/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

struct ChangeInviteDeeplink: Action {
    
    let inviteDeeplink: AppState.InviteDeeplink?
    
    func perform(initialState: AppState) -> AppState {
        var state = initialState
        state.inviteDeeplink = inviteDeeplink
        return state
    }
    
}


struct ChangeOpeRoomRef: Action {
    
    let roomRef: RoomRef
    
    func perform(initialState: AppState) -> AppState {
        var state = initialState
        state.openRoomRef = roomRef
        return state
    }
    
}

struct OpenCard: Action {
    
    let cardId: String
    let senderId: String
    
    func perform(initialState: AppState) -> AppState {
        var state = initialState
        state.openCard = .init(cardId: cardId, senderId: senderId)
        return state
    }
    
}

struct OpenCollection: Action {
    
    let collectionId: String
    
    func perform(initialState: AppState) -> AppState {
        var state = initialState
        state.openCollection = .init(id: collectionId)
        return state
    }
    
}
