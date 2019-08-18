//
//  StoreMainCards.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 8/18/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

struct StoreMainCards: Action {
    
    let cards: [Fantasy.Card]
    
    func perform(initialState: AppState) -> AppState {
        var state = initialState
        state.fantasies.cards = cards
        return state
    }
    
}
