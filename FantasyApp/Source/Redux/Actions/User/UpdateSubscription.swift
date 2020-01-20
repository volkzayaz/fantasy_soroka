//
//  UpdateSubscription.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 29.11.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift

struct UpdateSubscription: ActionCreator {
    
    let with: User.Subscription
    
    func perform(initialState: AppState) -> Observable<AppState> {
        
        return Fantasy.Manager.fetchSwipesDeck()
            .map { (deck) in
                var state = initialState
                state.currentUser?.subscription = self.with
                
                ///this is trigget to reload data in collections list
                state.currentUser?.fantasies.purchasedCollections = [Fantasy.Collection.fake]
                
                state.fantasiesDeck = deck
                return state
            }
            .asObservable()
            .catchErrorJustReturn(initialState)
        
        
    }
    
}
