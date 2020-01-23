//
//  File.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 23.01.2020.
//  Copyright © 2020 Fantasy App. All rights reserved.
//

import Foundation

struct ChangeIncommingConnections: Action {
    
    let count: Int
    
    func perform(initialState: AppState) -> AppState {
        var x = initialState
        x.incommingConnections = count
        return x
    }
    
}
