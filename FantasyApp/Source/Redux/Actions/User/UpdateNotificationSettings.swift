//
//  UpdateNotificationSettings.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 10/9/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift

struct UpdateNotificationSettings: ActionCreator {

    let mapper: (inout NotificationSettings) -> Void
    
    func perform(initialState: AppState) -> Observable<AppState> {
        
        guard var settings = initialState.currentUser?.notificationSettings else {
            return .just(initialState)
        }
        
        mapper(&settings)
        
        ///stakeholders wanna save changes right away
        return settings.pfObject.rxSave()
            .map { _ in
                var state = initialState
                state.currentUser?.notificationSettings = settings
                return state
            }
            .catchErrorJustReturn(initialState)
            .asObservable()
    
    }
    
}
