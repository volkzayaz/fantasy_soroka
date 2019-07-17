//
//  AppState.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 7/16/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

struct User {
    
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
