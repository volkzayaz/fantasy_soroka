//
//  EditProfilePhoto.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/5/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift

struct AddProfilePhoto: Action {
    
    let newPhoto: Photo
    let isPublic: Bool
    
    func perform(initialState: AppState) -> AppState {
        var state = initialState
        
        if isPublic {
            state.currentUser?.bio.photos.public.images.append( newPhoto )
        }
        else {
            state.currentUser?.bio.photos.private.images.append( newPhoto )
        }
        
        return state
    }
    
}

struct RemoveProfilePhoto: ActionCreator {
    
    let byIndex: Int
    let isPublic: Bool
    
    func perform(initialState: AppState) -> Observable<AppState> {
        var state = initialState
        
        var album: Album!
        if isPublic {
            album = state.currentUser?.bio.photos.public
        }
        else {
            album = state.currentUser?.bio.photos.private
        }
        
        let request = UserManager.dropPhoto(fromAlbum: album, index: byIndex)
        
        album.images.remove(at: byIndex)
        
        if isPublic {
            state.currentUser?.bio.photos.public = album
        }
        else {
            state.currentUser?.bio.photos.private = album
        }
            
        return request.asObservable()
            .startWith( () )/// sending deleted image state prediction right away
            .map { _ in state }
            .catchErrorJustReturn(initialState)
        
    }
    
}
