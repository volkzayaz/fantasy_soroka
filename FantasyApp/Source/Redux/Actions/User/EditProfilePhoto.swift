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
            state.currentUser?.bio.photos.public.images.append( Photo(url: newPhoto, thumbnailURL: newPhoto) )
        }
        else {
            state.currentUser?.bio.photos.private.images.append( Photo(url: newPhoto, thumbnailURL: newPhoto) )
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
            state.currentUser?.bio.photos.public.images.remove(at: byIndex)
        }
        else {
            state.currentUser?.bio.photos.private.images.remove(at: byIndex)
        }
        
        return state
    }
    
}
