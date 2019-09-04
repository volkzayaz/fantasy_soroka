//
//  ResetSwipeState.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 8/15/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

struct ResetSwipeRestriction: Action {
    
    let restriction: AppState.SwipeState.Restriction
    
    func perform(initialState: AppState) -> AppState {
        var state = initialState
        state.fantasies.restriction = restriction
        return state
    }
    
}
