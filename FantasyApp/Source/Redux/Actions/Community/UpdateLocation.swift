//
//  UpdateLocation.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 7/30/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

struct UpdateLocation: Action {
    
    let with: CLLocation
    
    func perform(initialState: AppState) -> AppState {
        var state = initialState
        state.lastKnownLocation = with
        return state       
    }
    
}
