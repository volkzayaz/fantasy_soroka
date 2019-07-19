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
    
    _appState.accept(AppState(currentUser: nil))
    
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
}

struct User: Equatable {
    
    var auth: AuthData
    var bio: Bio
    var preferences: SexPreference
    var fantasies: [Fantasy]
    var community: Community
    var connections: Connections
    var premiumFeatures: Set<PremiumFeature>
    var privacy: Privacy
    
    struct AuthData {
        let email: String?
        let fbData: String?
    };
    
    struct Bio {
        var name: String
        var birthday: Date
        var gender: Gender
        var photos: Photos
        
        enum Gender {
            case male, female
            case transexual
            case apacheHelicopter
            case other
        };
      
        struct Photos {
            var `public`: [String]
            var `private`: [String]
        };
    };

    struct SexPreference {
        
        var lookingFor: [Bio.Gender]
        var kinks: Set<Kink>
        
        enum Kink {
            case bj, bdsm, MILF
        };
        
    };
    
    struct Connections {
        
        var likeRequests: [UserSlice]
        var chatRequests: [UserSlice] ///message or sticker...
        
        var rooms: [Room]
        
    }

    enum PremiumFeature {
        case teleport
        case privateMode
        case matchSettings
        case unlimitedSwipes
        case screenShield
    }
    
    struct Privacy {
        let privateMode: Bool
        let disabledMode: Bool
        let blockedList: Set<UserSlice>
    }
    
}

struct Fantasy {
    let name: String
    let descriptiveData: Any
}

struct Room {
    
    let chatRef: Any ///data to identify chatting entity
    let peer: UserSlice
    
    var fantasies: [Fantasy]
    
}

struct Community {
    
    let region: CLRegion
    
    ///or define Community by any other geographical attribute
    
}

struct UserSlice: Hashable {
    let name: String
    let avatar: String?
    
    ///just enough data to display peer and fetch full data if needed
    
    ///for example show him near chat bubble or in like requests
    
}


extension Dispatcher {
    
    static var state: BehaviorRelay<AppState?> {
        return _appState
    }
    
}
