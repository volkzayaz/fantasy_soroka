//
//  User.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 7/27/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

struct User: Equatable, Hashable, Codable, UserDefaultsStorable {
    
    let id: String
    //var auth: AuthData
    
    var bio: Bio
    var fantasies: Fantasies
    var community: Community?
    
//    var preferences: SexPreference
//
    var connections: Connections
//    var privacy: Privacy
//
    //    ////Extract into Application property rather than User property
    //    var premiumFeatures: Set<PremiumFeature>
    
    
    enum AuthData: Equatable {
        case email(String)
        case fbData(String)
    };
    
    struct Bio: Equatable, Codable {
        var name: String
        var about: String?
        var birthday: Date
        var gender: Gender
        var sexuality: Sexuality
        var relationshipStatus: RelationshipStatus
        var photos: Photos
        
        struct Photos: Equatable, Codable {
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
    
    struct Connections: Equatable, Codable {
        
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
    
    struct Fantasies: Equatable, Codable {
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

struct Community: Codable, Equatable, ParsePresentable {
    
    static var className: String {
        return "NewCommunity"
    }
    
    var objectId: String?
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

enum Sexuality: String, CaseIterable, Equatable, Codable {
    
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

enum Gender: String, CaseIterable, Equatable, Codable {
    
    case male
    case female
    case transgenderMale = "MtF"
    case transgenderFemale = "FtM"
    case nonBinary
    
}

enum RelationshipStatus: Equatable, Codable {
    
    case single
    case couple(partnerGender: Gender)
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        try container.encode(description)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        let str = try container.decode(String.self)
        
        if str == "single" {
            self = .single
            return
        }
        
        if str.starts(with: "with") {
            self = .couple(partnerGender: Gender(rawValue: String(str.split(separator: " ").last!))!)
        }
        
        fatalError("Can't decode RelationshipStatus from \(str)")
    }
    
    var description: String {
        switch self {
        case .single:
            return "single"
        case .couple(let partnerGender):
            return "with \(partnerGender.rawValue)"
        
        }
    }
    
}

