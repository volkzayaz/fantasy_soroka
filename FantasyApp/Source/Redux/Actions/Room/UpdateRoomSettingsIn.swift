//
//  UpdateRoomNotificationSettings.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 19.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift

struct UpdateRoomSettingsIn: ActionCreator {

    let room: Room

    func perform(initialState: AppState) -> Observable<AppState> {

        return RoomManager.updateRoomSettings(roomId: room.id, settings: room.settings)
            .map { _ in

                if self.room.status != .ready {
                    return initialState
                }
                
                guard let i = initialState.rooms?.firstIndex(where: { $0.id == self.room.id }) else {
                    fatalErrorInDebug("Can't update settings of room that is not in the rooms list")
                    return initialState
                }
                
                var state = initialState
                state.rooms?[i] = self.room
                return state
            }
            .catchErrorJustReturn(initialState)
            .asObservable()
    }

}

struct UpdateRoomSharedCollections: ActionCreator {

    let room: Room

    func perform(initialState: AppState) -> Observable<AppState> {

        return RoomManager.updateRoomSharedCollections(room: room)
            .map { _ in
                
                guard let i = initialState.rooms?.firstIndex(where: { $0.id == self.room.id }) else {
                    return initialState
                }
                
                var state = initialState
                state.rooms?[i] = self.room
                return state
            }
            .catchErrorJustReturn(initialState)
            .asObservable()
    }

}


struct UpdateRoom: Action {

    let room: Room

    func perform(initialState: AppState) -> AppState {

        guard let i = initialState.rooms?.firstIndex(where: { $0.id == self.room.id }) else {
            return initialState
        }
        
        var state = initialState
        state.rooms?[i] = self.room
        return state
        
    }

}
