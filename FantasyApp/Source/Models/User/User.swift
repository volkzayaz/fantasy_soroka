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
    
    var community: Community
    
    var connections: Connections
//    var privacy: Privacy
    
    var searchPreferences: SearchPreferences?
    
    var discoveryFilter: DiscoveryFilter? {
        
        guard let x = searchPreferences,
              let y = community.value else { return nil }
        
        return DiscoveryFilter(filter: x, community: y)
    }
    
    var subscription: Subscription
    var notificationSettings: NotificationSettings
    
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
        var lookingFor: LookingFor?
        var expirience: Expirience?
        var answers: PersonalQuestion
        
        struct Photos: Equatable, Codable {
            
            ///All Album rlated activities are done on new Backend
            ///however Users are still queried via Parse API
            ///And parse knows nothing about Albums
            ///As a temporary workaround Backend sets value of main Photo from Main Album
            ///into Parse fields
            ///this way we don't need to query new server for Photo
            ///every time we wanna fetch user details
            ///
            ///TODO: this should be nonnullable entity when we migrate User to new backend
            var avatar: Photo
            
            var `public`: Album
            var `private`: Album
        };
        
        typealias PersonalQuestion = [String: String]
        
    };
    
    struct Connections: Equatable, Codable {
        
        var likeRequests: [UserSlice]
        var chatRequests: [UserSlice] ///message or sticker...
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
    
    struct Community: Equatable, Codable {
        var value: FantasyApp.Community?
        var changePolicy: CommunityChangePolicy
    }
    
    enum CommunityChangePolicy: Int, Equatable, Codable {
        case teleport = 1
        case locationBased = 2
    }
    
    static var current: User? {
        return appStateSlice.currentUser
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(bio.name)
    }
 
    static var query: PFQuery<PFObject> {
        return PFUser.query()!.includeKey("belongsTo")
    }
    
    struct Subscription: Codable, Equatable {
        
        enum CodingKeys: String, CodingKey {
            case status = "subscription"
        }
        
        var isSubscribed: Bool {
            return (status?.endDate.timeIntervalSinceNow ?? -1) > 0
        }
        let status: Status?
        
        struct Status: Codable, Equatable {
            let endDate: Date
        }
        
    }
    
}

struct Community: Codable, Equatable, ParsePresentable {
    
    static var className: String {
        return "NewCommunity"
    }
    
    var objectId: String?
    let name: String
    let country: String
    
    init() {
        fatalError("Do not use. Swift freaks out for some reason without this init. Process is terminated with Bad_Access if you try creating Value ")
    }
    
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
    
    case asexual = "Asexual"
    case questioning = "Questioning"
    case sapiosexual = "Sapiosexual"
    case transsexual = "Transsexual"
    case straight = "Straight"
    case heteroflexible = "Heteroflexible"
    case pansexual = "Pansexual"
    case queer = "Queer"
    case bisexual = "Bisexual"
    case lesbian = "Lesbian"
    case homoflexible = "Homoflexible"
    case gay = "Gay"
    
}

enum Gender: String, CaseIterable, Equatable, Codable {
    
    case transgenderMale = "MtF"
    case male
    case female
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
            return
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

enum LookingFor: Int, Codable, Equatable {
    
    case relationship = 0
    case someoneToPlayWith
    case princesDaySlutNight
    case friendship
    case sleepPartners
    
    var description: String {
        
        switch self {
            
        case .relationship: return "Relationship"
        case .someoneToPlayWith: return "Someone to play with"
        case .princesDaySlutNight: return "Princes by day, slut by night"
        case .friendship: return "Friendship"
        case .sleepPartners: return "Sleep partners"
            
        }
        
    }
    
}

enum Expirience: Int, Codable, Equatable {
    
    case veryExpirienced = 0
    case somewhereInTheMiddle
    case curious
    case brandNew
    case curiousAndLooking
    
    var description: String {
        
        switch self {
            
        case .veryExpirienced: return "Very expirienced"
        case .somewhereInTheMiddle: return "Somewhere in the middle"
        case .curious: return "Curious"
        case .brandNew: return "Brand New"
        case .curiousAndLooking: return "Curious And Looking"
            
        }
        
    }
    
}

extension User.Bio.PersonalQuestion {
    static let question1: String = "What are you looking for?"
    static let question2: String = "Facts about me that surprise people"
    static let question3: String = "Two truths and a lie"
}
