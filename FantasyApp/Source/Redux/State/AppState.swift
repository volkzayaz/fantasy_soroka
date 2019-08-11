//
//  AppState.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 7/16/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

////Why not ReSwift:
///1. AppState should not be nil. It makes little sence having App without any State at all
///2. No Reactive subscriptions available
///3. Absence of Asyncronous Actions
///4. Separation between Actions and Reducers. IMHO they are the same thing.
///  If you use 10 different reducers to handle 1 action, you might as well create single piece of code,
///  that handles this state transform.
///  If you have a state, that is accessed and mutated in the single place, you might as well extract this state into ViewModel

fileprivate let _appState = BehaviorRelay<AppState?>(value: nil)

func initAppState() -> Maybe<Void> {
    
    ///we can use network requests here as well if we want to delay application initialization
    _appState.accept(AppState(currentUser: AuthenticationManager.currentUser(),
                              lastKnownLocation: nil))
    
    return .just( () )
}

var appStateSlice: AppState {
    return _appState.value!
}

var appState: Driver<AppState> {
    return _appState.asDriver().notNil()
}

struct AppState: Equatable {
    var currentUser: User?
    var lastKnownLocation: CLLocation?
}

extension Dispatcher {
    
    static var state: BehaviorRelay<AppState?> {
        return _appState
    }
    
}
