//
//  ResetSwipeState.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 8/15/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

struct ResetSwipeDeck: Action {
    
    let deck: AppState.FantasiesDeck
    
    func perform(initialState: AppState) -> AppState {
        var state = initialState
        state.fantasiesDeck = deck
        return state
    }
    
}
