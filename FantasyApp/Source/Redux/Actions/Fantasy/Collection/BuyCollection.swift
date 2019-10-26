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
        
        return Fantasy.Manager.fetchSwipesDeck()
            .asObservable()
            .map { deck in
                state.fantasiesDeck = deck
                return state
        }
        
    }
    
}
