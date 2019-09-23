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
        
        return PurchaseManager.purhcase(collection: collection).asObservable()
            .flatMap { _ -> Observable<AppState> in
        
                var state = initialState
                
                state.currentUser?.fantasies.purchasedCollections.append(self.collection)
                
                guard case .swipeCount(let swipesLeft) = state.fantasies.restriction else {
                    return .just(state)
                }

                let freeCards = Array(Fantasy.Card.fakes.prefix(swipesLeft))
                let payedCards = state.currentUser?.fantasies.purchasedCollections.flatMap { $0.cards } ?? []
                
                state.fantasies.cards = (freeCards + payedCards).shuffled()
                
                return .just( state )
                
                
                //fatalError("Put correct cards fetching here:")
//                return Fantasy.Manager.fetchMainCards(localLimit: swipesLeft).asObservable()
//                    .map { cards in
//                        state.fantasies.cards = cards
//                        state.fantasies.restriction = .swipeCount(swipesLeft)
//
//                        return state
//                }
                
            }
        
    }
    
}
