//
//  UpdateRoomNotificationSettings.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 19.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift

struct UpdateRoomNotificationSettings: ActionCreator {

    let roomId: String
    let mapper: (inout RoomNotificationSettings) -> Void

    func perform(initialState: AppState) -> Observable<AppState> {

        guard var settings = initialState.currentUser?.roomsNotificationSettings?
            .first(where: { $0.roomId == roomId }) else {
            return .just(initialState)
        }

        mapper(&settings)

        ///stakeholders wanna save changes right away
        return settings.pfObject.rxSave()
            .map { _ in
                var state = initialState
                if let index = state.currentUser?.roomsNotificationSettings?
                    .firstIndex(where: { $0.roomId == self.roomId }) {
                     state.currentUser?.roomsNotificationSettings?[index] = settings
                }

                return state
            }
            .catchErrorJustReturn(initialState)
            .asObservable()
    }

}
