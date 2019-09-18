//
//  UpdateCommunity.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/18/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import RxSwift

struct UpdateCommunity: ActionCreator {
    
    let with: Community?
    
    func perform(initialState: AppState) -> Observable<AppState> {
        
        guard let user = initialState.currentUser,
              user.community != with else {
            return .just(initialState)
        }
        
        var state = initialState
        state.currentUser?.community = with
        
        return user.toCurrentPFUser.rxSave()
            .asObservable()
            .map { _ in state }
    }
    
}
