//
//  User.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 7/27/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

struct User: Equatable {
    
    var auth: AuthData
    var bio: Bio
    var preferences: SexPreference
    var fantasies: Fantasies
    var community: Community
    var connections: Connections
    var privacy: Privacy
    
    //    ////Extract into Application property rather than User property
    //    var premiumFeatures: Set<PremiumFeature>
    
    
    enum AuthData: Equatable {
        case email(String)
        case fbData(String)
    };
    
    struct Bio: Equatable {
        var name: String
        var birthday: Date
        var gender: Gender
        var sexuality: Sexuality
        var relationshipStatus: RelationshipStatus
        var photos: Photos
        
        struct Photos: Equatable {
            var `public`: [String]
            var `private`: [String]
        };
        
    };
    
    struct SexPreference: Equatable {
        
        var lookingFor: [Gender]
        var kinks: Set<Kink>
        
        enum Kink {
            case bj, bdsm, MILF
        };
        
    };
    
    struct Connections: Equatable {
        
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
    
    struct Privacy: Equatable {
        let privateMode: Bool
        let disabledMode: Bool
        let blockedList: Set<UserSlice>
    }
    
    struct Fantasies: Equatable {
        var liked: [Fantasy.Card]
        var disliked: [Fantasy.Card]
    }
    
    static var current: User? {
        return AuthenticationManager.currentUser()
    }
    
}

struct Room: Equatable {
    
    //let chatRef: Any ///data to identify chatting entity
    let peer: UserSlice
    
    var fantasies: [Fantasy.Card]
    
}

struct Community: Equatable {
    
    ///or define Community by any other geographical attribute
    //let region: CLRegion
    
}

struct UserSlice: Hashable, Codable, Equatable {
    let name: String
    let avatar: String?
    
    ///just enough data to display peer and fetch full data if needed
    
    ///for example show him near chat bubble or in like requests
    
}

enum Sexuality: String, CaseIterable, Equatable {
    
    case straight = "Straight"
    case gay = "Gay"
    case lesbian = "Lesbian"
    case bisexual = "Bisexual"
    case asexual = "Asexual"
    case pansexual = "Pansexual"
    case queer = "Queer"
    case questioning = "Questioning"
    case heteroflexible = "Heteroflexible"
    case homoflexible = "Homoflexible"
    case sapiosexual = "Sapiosexual"
    case transsexual = "Transsexual"
    
}

enum Gender: String, CaseIterable, Equatable {
    
    case male
    case female
    case transgenderMale = "MtF"
    case transgenderFemale = "FtM"
    case nonBinary
    
}

enum RelationshipStatus: Equatable {
    
    case single
    case couple(partnerGender: Gender)
    
}

