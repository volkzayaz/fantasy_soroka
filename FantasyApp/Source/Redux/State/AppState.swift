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
    _appState.accept(
        AppState(currentUser: AuthenticationManager.currentUser(),
                 fantasiesDeck: .init(cards: nil, wouldUpdateAt: nil),
                 incommingConnections: 0
        )
    )
    
    let _ =
    NotificationCenter.default.rx.notification(UIApplication.willTerminateNotification)
        .subscribe(onNext: { (_) in
            SettingsStore.currentUser.value = _appState.value!.currentUser
        })
    
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
    
    var rooms: [Room]? = nil
    var reloadRoomsTriggerBecauseOfComplexFreezeLogic = false
    
    var fantasiesDeck: FantasiesDeck
    
    var incommingConnections: Int
    
    var inviteDeeplink: InviteDeeplink?
    var openRoom: OpenRoom?
    var openCard: OpenCard?
    var openCollection: OpenCollection?
    
    var justice: Bool = false
    
    struct FantasiesDeck: Equatable {
        
        var cards:[Fantasy.Card]?
        var wouldUpdateAt: Date?
        
    };
    
    struct OpenRoom: Equatable {
        let udid = UUID().uuidString
        let roomRef: RoomRef
    }
    
    
    struct InviteDeeplink: Equatable {
        let roomRef: RoomRef
        let password: String
    }
    
    struct OpenCard: Equatable {
        let udid = UUID().uuidString
        let cardId: String
        let senderId: String
    }
    
    struct OpenCollection: Equatable {
        let udid = UUID().uuidString
        let id: String
    }
    
}

extension Dispatcher {
    
    static var state: BehaviorRelay<AppState?> {
        return _appState
    }
    
}
