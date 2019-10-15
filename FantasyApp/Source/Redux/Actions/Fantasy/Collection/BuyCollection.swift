//
//  BuyCollection.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 8/21/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import RxSwift

struct BuyCollection: ActionCreator {
    
    let collection: Fantasy.Collection
    
    func perform(initialState: AppState) -> Observable<AppState> {
        
        var state = initialState
        
        state.currentUser?.fantasies.purchasedCollections.append(self.collection)
        
        guard case .swipeCount(let swipesLeft) = state.fantasies.restriction else {
            return .just(state)
        }
        
        return Fantasy.Manager.fetchMainCards()
            .asObservable()
            .map { cards in
                state.fantasies.cards = cards
                return state
        }
        
    }
    
}
