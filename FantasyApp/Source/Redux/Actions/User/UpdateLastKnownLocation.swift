//
//  UpdateLastKnownLocation.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 19.11.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

struct UpdateLastKnownLocation: Action {
    
    let location: CLLocation
    
    func perform(initialState: AppState) -> AppState {
        var state = initialState
        
        guard let _ = state.currentUser else {
            return initialState
        }
        
        state.currentUser?.community.lastKnownLocation = .init(location: location)
        
        let _ = state.currentUser!.toCurrentPFUser.rxSave().subscribe()
        
        return state
    }
    
}

struct UpdateLastAssosiatedTown: Action {
    
    let with: String?
    
    func perform(initialState: AppState) -> AppState {
        var state = initialState
        state.currentUser?.community.lastKnownLocation?.assosiatedTown = with
        return state
    }
    
}
