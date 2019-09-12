//
//  EditProfilePhoto.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/5/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

struct AddProfilePhoto: Action {
    
    let newPhoto: String
    let isPublic: Bool
    
    func perform(initialState: AppState) -> AppState {
        var state = initialState
        
        if isPublic {
            state.currentUser?.bio.photos.public.append(newPhoto)
        }
        else {
            state.currentUser?.bio.photos.private.append(newPhoto)
        }
        
        return state
    }
    
}

struct RemoveProfilePhoto: Action {
    
    let byIndex: Int
    let isPublic: Bool
    
    func perform(initialState: AppState) -> AppState {
        var state = initialState
        
        if isPublic {
            state.currentUser?.bio.photos.public.remove(at: byIndex)
        }
        else {
            state.currentUser?.bio.photos.private.remove(at: byIndex)
        }
        
        return state
    }
    
}
