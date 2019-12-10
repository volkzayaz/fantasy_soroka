//
//  SetUser.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 7/28/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

struct SetUser: Action {
    
    let user: User?
    
    func perform(initialState: AppState) -> AppState {
        var state = initialState
        
        ///this state save should really belong elsewhere
        SettingsStore.currentUser.value = user
        
        state.currentUser = user
        return state
    }
    
}

struct Logout: Action {
    
    func perform(initialState: AppState) -> AppState {
        return AppState(currentUser: nil,
                        fantasiesDeck: .init(cards: [], wouldUpdateAt: nil),
                        inviteDeeplink: nil)
    }
    
}
