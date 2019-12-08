//
//  User.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 7/27/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxCocoa

struct User: Equatable, Hashable, Codable, UserDefaultsStorable {
    
    let id: String
    //var auth: AuthData
    
    var bio: Bio
    var fantasies: Fantasies
    
    var community: Community
    
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
        
        var yearsOld: String {
            return "\(Calendar.current.dateComponents([.year], from: birthday, to: Date()).year!)"
        }
        
    };
    
    enum PremiumFeature {
        case teleport
        case privateMode
        case matchSettings
        case unlimitedSwipes
        case screenShield
    }
    
//    struct Privacy: Equatable {
//        let privateMode: Bool
//        let disabledMode: Bool
//        let blockedList: Set<UserSlice>
//    }
    
    struct Fantasies: Equatable, Codable {
        var liked: [Fantasy.Card]
        var disliked: [Fantasy.Card]
        
        var purchasedCollections: [Fantasy.Collection]
    }
    
    struct Community: Equatable, Codable {
        var value: FantasyApp.Community?
        var changePolicy: CommunityChangePolicy
        var lastKnownLocation: LastKnownLocation?
    }
    
    enum CommunityChangePolicy: Int, Equatable, Codable {
        case teleport = 1
        case locationBased = 2
    }
    
    struct LastKnownLocation: Codable, Equatable {
        let latitude: Double
        let longitude: Double
        
        init(location: CLLocation) {
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
        }
        
        init(pfGeoPoint: PFGeoPoint) {
            latitude = pfGeoPoint.latitude
            longitude = pfGeoPoint.longitude
        }
        
        var pfGeoPoint: PFGeoPoint {
            return PFGeoPoint(latitude: latitude, longitude: longitude)
        }
        
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
    
    
    static var changesOfSubscriptionStatus: Driver<Bool> {
        return appState.changesOf { $0.currentUser?.subscription.isSubscribed }
            .map { $0 ?? false }
    }
    
}

struct Community: Codable, Equatable, ParsePresentable {
    
    static var className: String {
        return "NewCommunity"
    }
    
    var objectId: String?
    let name: String
    let country: String
    let sortOrder: Int 
    
    init() {
        fatalError("Do not use. Swift freaks out for some reason without this init. Process is terminated with Bad_Access if you try creating Value ")
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

extension Sexuality: SwipebleModel {

    var name: String {
        return self.rawValue
    }

   static func sexuality(by index: Int) -> Sexuality {
       return allCases[index]
    }

    static func index(by sexuality: Sexuality) -> Int {
        return allCases.firstIndex(of: sexuality) ?? 0
    }
}


enum Gender: String, CaseIterable, Equatable, Codable {
    
    case transgenderMale = "MtF"
    case male
    case female
    case transgenderFemale = "FtM"
    case nonBinary

    var pretty: String {
        switch self {
        case .transgenderMale: return "Transgender Male"
        case .male: return "Male"
        case .female: return "Female"
        case .transgenderFemale: return "Transgender Female"
        case .nonBinary: return "Non-binary"
        }
    }
}

extension Gender: SwipebleModel {

    var name: String {
        return self.pretty
    }

   static func gender(by index: Int) -> Gender {
       return allCases[index]
    }

    static func index(by gender: Gender) -> Int {
        return allCases.firstIndex(of: gender) ?? 0
    }
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

    var partnerGender: Gender? {
        switch self {
        case .single:
            return nil
        case .couple(let partnerGender):
            return partnerGender
        }
    }
    
    var description: String {
        switch self {
        case .single:
            return "single"
        case .couple(let partnerGender):
            return "with \(partnerGender.rawValue)"
        
        }
    }
    
    var pretty: String {
        switch self {
        case .single:
            return "Single"
        case .couple(let partnerGender):
            return "with \(partnerGender.pretty)"
        
        }
    }
    
    var analyticsTuple: (String, String?) {
        switch self {
            case .single                   : return ("Solo", nil)
            case .couple(let partnerGender): return ("Couple", partnerGender.rawValue)
        }
    }
}

enum LookingFor: Int, Codable, Equatable, CaseIterable {
    
    case relationship = 0
    case someoneToPlayWith
    case princesDaySlutNight
    case friendship
    case ethicalNonMono
    case sleepPartners
    case bdsm
    case polyNetwork
    case unicorn
    case beAUnicorn
    case joinAnEstablishedCouple
    
    var description: String {
        
        switch self {
            
        case .relationship: return "Relationship"
        case .someoneToPlayWith: return "Someone to play with"
        case .princesDaySlutNight: return "Princes by day, slut by night"
        case .friendship: return "Friendship"
        case .ethicalNonMono: return "Ethical non-monogamous relationship"
        case .sleepPartners: return "Sleep partners"
        case .bdsm: return "BDSM Relationship"
        case .polyNetwork: return "Poly network"
        case .unicorn: return "To be a unicorn"
        case .beAUnicorn: return "To be a unicorn"
        case .joinAnEstablishedCouple: return "To join an established couple"
            
        }
        
    }
    
}

enum Expirience: Int, Codable, Equatable, CaseIterable {
    
    case professional = 0
    case iveDoneItAll
    case veryExpirienced
    case upForAnything
    case somewhereInTheMiddle
    case alilBitOfThisNThat
    case newButReadyForAnything
    case curiousAndLooking
    case vanilla
    case brandNew
    
    var description: String {
        
        switch self {
            
        case .professional: return "Professional"
        case .iveDoneItAll: return "I’ve done it all"
        case .veryExpirienced: return "Very experienced"
        case .upForAnything: return "Up for anything"
        case .somewhereInTheMiddle: return "Somewhere in the middle"
        case .alilBitOfThisNThat: return "A little of this, a little of that"
        case .newButReadyForAnything: return "New but ready for (almost) anything"
        case .curiousAndLooking: return "Curious and looking"
        case .vanilla: return "Vanilla"
        case .brandNew: return "Brand new"
            
        }
        
    }
    
}

extension User.Bio.PersonalQuestion {
    static let question1: String = "Which 3 words describe me the best?"
    static let question2: String = "What motto do I live by?"
    static let question3: String = "What is on the top of my bucket list?"
}


//extension User {
//
//    static var daUser: User {
//
//        ImageRetreiver.registerImage(image: UIImage(named: "ava.png")!,
//                                     forKey: "https://ava.com")
//
//        ImageRetreiver.registerImage(image: UIImage(named: "photo1.png")!,
//                                     forKey: "https://photo1.com")
//
//        ImageRetreiver.registerImage(image: UIImage(named: "photo2.png")!,
//                                     forKey: "https://photo2.com")
//        return User(id: UUID().uuidString,
//        bio: User.Bio(name: "Jacksonvillemandela Aguera perero Blanco marcelo",
//                      about: "I am beautifull girl with extraordinary fantasies and passion to flirt no matter a girl or guy! 🦄🌈",
//                      birthday: Date(timeIntervalSince1970: 12345678),
//                      gender: .female,
//                      sexuality: .queer,
//                      relationshipStatus: .single,
//                      photos: .init(avatar: .init(id: "x",
//                                                  url: "https://ava.com",
//                                                  thumbnailURL: "https://ava.com"),
//                                    public: .init(images: [
//                                        .init(id: "y",
//                                              url: "https://photo1.com",
//                                              thumbnailURL: "https://photo1.com")], id:" "),
//                                    private: .init(images: [
//                                        .init(id: "z",
//                                              url: "https://photo2.com",
//                                              thumbnailURL: "https://photo2.com")])),
//                      lookingFor: .friendship,
//                      expirience: .curious,
//                      answers: [
//                        "What?" : "That and that and that",
//                        "Wassup?" : "It's aight hommie, Imma go get us some bitches"
//        ]),
//        fantasies: .init(liked: [], disliked: [], purchasedCollections: []),
//        community: User.Community(value: nil,
//                                  changePolicy: .locationBased),
//        connections: .init(likeRequests: [],
//                           chatRequests: []),
//        searchPreferences: nil,
//        subscription: .init(status:
//            .init(endDate: Date(timeIntervalSinceNow: Double(1234)))
//        ),
//        notificationSettings: NotificationSettings(),
//        roomsNotificationSettings: nil)
//
//    }
//
//    static var daUser1: User {
//
//           ImageRetreiver.registerImage(image: UIImage(named: "photo1.png")!,
//                                        forKey: "https://photo1.com")
//
//           ImageRetreiver.registerImage(image: UIImage(named: "photo1.png")!,
//                                        forKey: "https://photo1.com")
//
//           ImageRetreiver.registerImage(image: UIImage(named: "photo2.png")!,
//                                        forKey: "https://photo2.com")
//           return User(id: UUID().uuidString,
//           bio: User.Bio(name: "Nency",
//                         about: "I am beautifull girl with extraordinary fantasies and passion to flirt no matter a girl or guy! 🦄🌈",
//                         birthday: Date(timeIntervalSince1970: 12345678),
//                         gender: .female,
//                         sexuality: .queer,
//                         relationshipStatus: .single,
//                         photos: .init(avatar: .init(id: "x",
//                                                     url: "https://photo1.com",
//                                                     thumbnailURL: "https://photo1.com"),
//                                       public: .init(images: [
//                                           .init(id: "y",
//                                                 url: "https://photo1.com",
//                                                 thumbnailURL: "https://photo1.com")], id:" "),
//                                       private: .init(images: [
//                                           .init(id: "z",
//                                                 url: "https://photo2.com",
//                                                 thumbnailURL: "https://photo2.com")])),
//                         lookingFor: .friendship,
//                         expirience: .curious,
//                         answers: [
//                           "What?" : "That and that and that",
//                           "Wassup?" : "It's aight hommie, Imma go get us some bitches"
//           ]),
//           fantasies: .init(liked: [], disliked: [], purchasedCollections: []),
//           community: User.Community(value: nil,
//                                     changePolicy: .locationBased),
//           connections: .init(likeRequests: [],
//                              chatRequests: []),
//           searchPreferences: nil,
//           subscription: .init(status:
//               .init(endDate: Date(timeIntervalSinceNow: Double(1234)))
//           ),
//           notificationSettings: NotificationSettings(),
//           roomsNotificationSettings: nil)
//
//       }
//
//    static var daUser2: User {
//
//           ImageRetreiver.registerImage(image: UIImage(named: "photo1.png")!,
//                                        forKey: "https://photo1.png")
//
//           ImageRetreiver.registerImage(image: UIImage(named: "photo1.png")!,
//                                        forKey: "https://photo1.com")
//
//           ImageRetreiver.registerImage(image: UIImage(named: "photo2.png")!,
//                                        forKey: "https://photo2.com")
//           return User(id: UUID().uuidString,
//           bio: User.Bio(name: "Karen",
//                         about: "I am beautifull girl with extraordinary fantasies and passion to flirt no matter a girl or guy! 🦄🌈",
//                         birthday: Date(timeIntervalSince1970: 12345678),
//                         gender: .female,
//                         sexuality: .queer,
//                         relationshipStatus: .single,
//                         photos: .init(avatar: .init(id: "x",
//                                                     url: "https://photo2.com",
//                                                     thumbnailURL: "https://photo2.com"),
//                                       public: .init(images: [
//                                           .init(id: "y",
//                                                 url: "https://photo1.com",
//                                                 thumbnailURL: "https://photo1.com")], id:" "),
//                                       private: .init(images: [
//                                           .init(id: "z",
//                                                 url: "https://photo2.com",
//                                                 thumbnailURL: "https://photo2.com")])),
//                         lookingFor: .friendship,
//                         expirience: .curious,
//                         answers: [
//                           "What?" : "That and that and that",
//                           "Wassup?" : "It's aight hommie, Imma go get us some bitches"
//           ]),
//           fantasies: .init(liked: [], disliked: [], purchasedCollections: []),
//           community: User.Community(value: nil,
//                                     changePolicy: .locationBased),
//           connections: .init(likeRequests: [],
//                              chatRequests: []),
//           searchPreferences: nil,
//           subscription: .init(status:
//               .init(endDate: Date(timeIntervalSinceNow: Double(1234)))
//           ),
//           notificationSettings: NotificationSettings(),
//           roomsNotificationSettings: nil)
//
//       }
//
//}
