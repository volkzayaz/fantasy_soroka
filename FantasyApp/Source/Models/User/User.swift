//
//  User.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 7/27/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

struct User: Equatable, Hashable {
    
    let id: String
    var auth: AuthData
    
    var bio: Bio
    var fantasies: Fantasies
    var community: Community?
    
    var preferences: SexPreference
    
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
        var about: String?
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
        
        var rooms: [Chat.Room]
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
        
        var purchasedCollections: [Fantasy.Collection]
    }
    
    static var current: User? {
        return appStateSlice.currentUser
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(bio.name)
    }
    
}

struct Community: Codable, Equatable {
    
    ///or define Community by any other geographical attribute
    //let region: CLRegion
    let name: String
    
}

struct UserSlice: Hashable, Codable, Equatable, ParsePresentable {
    let name: String
    let avatar: String?
    var objectId: String?

    static var className: String {
        return "User"
    }

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
    
    var description: String {
        switch self {
        case .single:
            return "single"
        case .couple(let partnerGender):
            return "with \(partnerGender.rawValue)"
        
        }
    }
    
}

