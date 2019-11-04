//
//  UpdateRoomNotificationSettings.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 19.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift

struct UpdateNotificationSettingsIn: ActionCreator {

    let room: Room

    func perform(initialState: AppState) -> Observable<AppState> {

        guard let i = initialState.rooms.firstIndex(of: room) else {
            fatalErrorInDebug("Can't update settings of room that is not in the rooms list")
            return .just(initialState)
        }
        
        return room.notificationSettings.pfObject.rxSave()
            .map { _ in
                var state = initialState
                state.rooms[i] = self.room
                return state
            }
            .catchErrorJustReturn(initialState)
            .asObservable()
    }

}
