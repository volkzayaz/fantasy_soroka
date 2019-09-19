//
//  UpdateSearchPreferences.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/19/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

struct UpdateSearchPreferences: Action {
    
    let with: SearchPreferences
    
    func perform(initialState: AppState) -> AppState {
        var x = initialState
        
        x.currentUser?.searchPreferences = with
        
        return x
    }
    
}
