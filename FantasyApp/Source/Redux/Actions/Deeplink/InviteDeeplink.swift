//
//  InviteDeeplink.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 10/26/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

struct ChangeInviteDeeplink: Action {
    
    let inviteToken: String?
    
    func perform(initialState: AppState) -> AppState {
        var state = initialState
        state.inviteDeeplink = inviteToken
        return state
    }
    
}
