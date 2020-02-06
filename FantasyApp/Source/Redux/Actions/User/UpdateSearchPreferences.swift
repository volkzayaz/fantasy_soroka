//
//  UpdateSearchPreferences.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/19/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift

struct UpdateSearchPreferences: ActionCreator {
    
    let with: SearchPreferences
    
    func perform(initialState: AppState) -> Observable<AppState> {
        
        guard var user = initialState.currentUser else {
            return .just(initialState)
        }
        
        user.searchPreferences = with
        
        var x = initialState
        x.currentUser = user
        
        return user.toCurrentPFUser.rxSave()
            .asObservable()
            .map { _ in x }
            .startWith(x)
        
    }
    
}
