//
//  User.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 7/27/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxCocoa
import RxDataSources

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
        
        let registrationDate: Date
        
        var name: String
        var about: String?
        var birthday: Date
        var gender: Gender
        var sexuality: Sexuality
        var relationshipStatus: RelationshipStatus
        var photos: Photos
        var lookingFor: [LookingFor]
        var expirience: Expirience?
        var answers: PersonalQuestion
        var flirtAccess: Bool?
        
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
        
        var clLocation: CLLocation {
            return CLLocation(latitude: latitude, longitude: longitude)
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
    
    case all = "All"
    
    var pretty: String {
        switch self {
        case .asexual: return R.string.localizable.sexualityAsexual()
        case .questioning: return R.string.localizable.sexualityQuestioning()
        case .sapiosexual: return R.string.localizable.sexualitySapiosexual()
        case .transsexual: return R.string.localizable.sexualityTranssexual()
        case .straight: return R.string.localizable.sexualityStraight()
        case .heteroflexible: return R.string.localizable.sexualityHeteroflexible()
        case .pansexual: return R.string.localizable.sexualityPansexual()
        case .queer: return R.string.localizable.sexualityQueer()
        case .bisexual: return R.string.localizable.sexualityBisexual()
        case .lesbian: return R.string.localizable.sexualityLesbian()
        case .homoflexible: return R.string.localizable.sexualityHomoflexible()
        case .gay: return R.string.localizable.sexualityGay()
        case .all: return R.string.localizable.sexualityAll()
        }
    }

    public init(from decoder: Decoder) throws {
        let legacy = try Sexuality(rawValue: decoder.singleValueContainer().decode(RawValue.self))
        
        guard let legacyVar = legacy else {
            throw ModelMigrationError.noLegacyModel
        }

        let migrated = legacyVar.toSexualityV2
        self = migrated
    }


    init?(fromFantasyRawValue: String) {
        guard let legacy = Sexuality(rawValue: fromFantasyRawValue) else {
            return nil
        }

        let migrated = legacy.toSexualityV2
        self = migrated
    }

    static var allCasesV2:[Sexuality] {
//        return allCases
        return allCases.filter { $0 != .all && $0 != .transsexual }
    }
}

extension Sexuality: SwipebleModel {

    var name: String {
        return self.rawValue
    }

    static func sexuality(by index: Int) -> Sexuality {
        return allCasesV2[index]
    }

    static func index(by sexuality: Sexuality) -> Int {
        return allCasesV2.firstIndex(of: sexuality) ?? 0
    }
}

enum ModelMigrationError: Error {
    case noLegacyModel
}

enum Gender: String, CaseIterable, Equatable, Codable {
    
    case male
    case female
    case nonBinary
//    case transgenderMale = "MtF"
//    case transgenderFemale = "FtM"

    var pretty: String {
        switch self {
        case .male: return R.string.localizable.genderMale()
        case .female: return R.string.localizable.genderFemale()
        case .nonBinary: return R.string.localizable.genderNonBinary()

//        case .transgenderMale: return "MtF"
//        case .transgenderFemale: return "FtM"
        }
    }

    public init(from decoder: Decoder) throws {

        let legacy = try GenderLegacy(rawValue: decoder.singleValueContainer().decode(RawValue.self))

        guard let legacyVar = legacy else {
            throw ModelMigrationError.noLegacyModel
        }

        self = legacyVar.toGenderV2
    }

    init?(fromFantasyRawValue: String) {
        guard let legacy = GenderLegacy(rawValue: fromFantasyRawValue) else {
            return nil
        }

        self = legacy.toGenderV2
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

enum RelationshipType: String, Equatable, CaseIterable, IdentifiableType {
    
    case single = "Single"
    case partnered = "Partnered"
    case inRelationship = "InRelationship"
    case engaged = "Engaged"
    case married = "Married"
    case dating = "Dating"
    case inPolyFamily = "InPolyFamily"
    case seeing = "Seeing"
    
    var identity: String { rawValue }
    
    var pretty: String {
        switch self {
        case .single:
            return R.string.localizable.relationshipStatusSingle()
        case .partnered:
            return R.string.localizable.relationshipStatusPartnered()
        case .inRelationship:
            return R.string.localizable.relationshipStatusInRelationship()
        case .engaged:
            return R.string.localizable.relationshipStatusEngaged()
        case .married:
            return R.string.localizable.relationshipStatusMarried()
        case .dating:
            return R.string.localizable.relationshipStatusDating()
        case .inPolyFamily:
            return R.string.localizable.relationshipStatusInPolyFamily()
        case .seeing:
            return R.string.localizable.relationshipStatusSeeing()
        }
    }
}

enum RelationshipStatus: Equatable, Codable {
    
    case single
    case partnered(partner: Gender)
    case inRelationship(partner: Gender)
    case engaged(partner: Gender)
    case married(partner: Gender)
    case dating(partner: Gender)
    case inPolyFamily(partner: Gender)
    case seeing(partner: Gender)
    
    var relationshipType: RelationshipType {
        switch self {
        case .single:
            return RelationshipType.single
        case .partnered:
            return RelationshipType.partnered
        case .inRelationship:
            return RelationshipType.inRelationship
        case .engaged:
            return RelationshipType.engaged
        case .married:
            return RelationshipType.married
        case .dating:
            return RelationshipType.dating
        case .inPolyFamily:
            return RelationshipType.inPolyFamily
        case .seeing:
            return RelationshipType.seeing
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }
    
    init(relationshipType: RelationshipType, partnerGender: Gender?) {
        if let partnerGender = partnerGender {
            switch relationshipType {
            case .partnered:
                self = .partnered(partner: partnerGender)
            case .inRelationship:
                self = .inRelationship(partner: partnerGender)
            case .engaged:
                self = .engaged(partner: partnerGender)
            case .married:
                self = .married(partner: partnerGender)
            case .dating:
                self = .dating(partner: partnerGender)
            case .inPolyFamily:
                self = .inPolyFamily(partner: partnerGender)
            case .seeing:
                self = .seeing(partner: partnerGender)
            default:
                self = .single
            }
        } else {
            self = .single
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let str = try container.decode(String.self)

        if str == "single" || str == RelationshipStatus.single.relationshipType.rawValue {
            self = .single
            return
        }

        if str.starts(with: "with") {
            self = .partnered(partner: Gender(fromFantasyRawValue: String(str.split(separator: " ").last!))!)
            return
        }

        let components = str.split(separator: " ")
        if components.count == 3, components[1] == "with", let relationshipType = RelationshipType(rawValue: String(components[0])), let gender = Gender(fromFantasyRawValue: String(components[2])) {
            self.init(relationshipType: relationshipType, partnerGender: gender)
            return
        }

        fatalError("Can't decode RelationshipStatus from \(str)")
    }

    var partnerGender: Gender? {
        switch self {
        case .single:
            return nil
        case .partnered(let partner), .inRelationship(let partner), .engaged(let partner), .married(let partner), .dating(let partner), .inPolyFamily(let partner), .seeing(let partner):
            return partner
        }
    }

    var description: String {
        switch self {
        case .single:
            return "Single"
        case .partnered(let partner), .inRelationship(let partner), .engaged(let partner), .married(let partner), .dating(let partner), .inPolyFamily(let partner), .seeing(let partner):
            return "\(relationshipType.rawValue) with \(partner.rawValue)"
        }
    }
    
    var pretty: String {
        switch self {
        case .single:
            return R.string.localizable.relationshipStatusSingle()
        case .partnered(let partner):
            return R.string.localizable.relationshipStatusWith(R.string.localizable.relationshipStatusPartnered(), partner.pretty)
        case .inRelationship(let partner):
            return R.string.localizable.relationshipStatusWith(R.string.localizable.relationshipStatusInRelationship(), partner.pretty)
        case .engaged(let partner):
            return R.string.localizable.relationshipStatusWith(R.string.localizable.relationshipStatusEngaged(), partner.pretty)
        case .married(let partner):
            return R.string.localizable.relationshipStatusWith(R.string.localizable.relationshipStatusMarried(), partner.pretty)
        case .dating(let partner):
            return R.string.localizable.relationshipStatusWith(R.string.localizable.relationshipStatusDating(), partner.pretty)
        case .inPolyFamily(let partner):
            return R.string.localizable.relationshipStatusWith(R.string.localizable.relationshipStatusInPolyFamily(), partner.pretty)
        case .seeing(let partner):
            return R.string.localizable.relationshipStatusWith(R.string.localizable.relationshipStatusSeeing(), partner.pretty)
        }
    }
    
    var analyticsTuple: (String, String?) {
        switch self {
        case .single:
            return ("Solo", nil)
        case .partnered(let partner), .inRelationship(let partner), .engaged(let partner), .married(let partner), .dating(let partner), .inPolyFamily(let partner), .seeing(let partner):
            return (relationshipType.rawValue, partner.rawValue)
        }
    }
}

// Parse
extension RelationshipStatus {

    init(pfUser: PFUser) {
        if let parseRelationshipStatus = pfUser["MyRelationshipStatus"] as? String, let relationshipType = RelationshipType(rawValue: parseRelationshipStatus), let parsePartnerGender = pfUser["MyPartnerGender"] as? String, let partner = Gender(fromFantasyRawValue: parsePartnerGender) {
            self.init(relationshipType: relationshipType, partnerGender: partner)
        } else {
            self = .single
        }
    }
}

enum LookingFor: Int, Codable, Equatable, CaseIterable {
    
    case relationship = 0
    case someoneToPlayWith
    case princesDaySlutNight
    case princeDaySlutNight
    case friendship
    case ethicalNonMono
    case sleepPartners
    case bdsm
    case polyNetwork
    case unicorn
    case beAUnicorn
    case joinAnEstablishedCouple
    case ideas
    case techniques
    case sexIQ
    case partner
    case friends
    case new
    
    var description: String {
        
        switch self {
            
        case .relationship: return R.string.localizable.lookingForRelationship()
        case .someoneToPlayWith: return R.string.localizable.lookingForSomeoneToPlayWith()
        case .princesDaySlutNight: return R.string.localizable.lookingForPrincesDaySlutNight()
        case .princeDaySlutNight: return R.string.localizable.lookingForPrinceDaySlutNight()
        case .friendship: return R.string.localizable.lookingForFriendship()
        case .ethicalNonMono: return R.string.localizable.lookingForEthicalNonMono()
        case .sleepPartners: return R.string.localizable.lookingForSleepPartners()
        case .bdsm: return R.string.localizable.lookingForBdsm()
        case .polyNetwork: return R.string.localizable.lookingForPolyNetwork()
        case .unicorn: return R.string.localizable.lookingForUnicorn()
        case .beAUnicorn: return R.string.localizable.lookingForBeAUnicorn()
        case .joinAnEstablishedCouple: return R.string.localizable.lookingForJoinAnEstablishedCouple()
        case .ideas: return R.string.localizable.lookingForIdeas()
        case .techniques: return R.string.localizable.lookingForTechniques()
        case .sexIQ: return R.string.localizable.lookingForSexIQ()
        case .partner: return R.string.localizable.lookingForPartner()
        case .friends: return R.string.localizable.lookingForFriends()
        case .new: return R.string.localizable.lookingForNew()
            
        }
    }
    
    
    
    static var sortedCases: [(String, [LookingFor])] {
        [
            (R.string.localizable.lookingForSectionLearn(), [
                .ideas,
                .techniques,
                .sexIQ
            ]),
            (R.string.localizable.lookingForSectionPlay(), [
                .partner,
                .friends,
                .new
            ]),
            (R.string.localizable.lookingForSectionFlirt(), [
                .relationship,
                .someoneToPlayWith,
                .princesDaySlutNight,
                .princeDaySlutNight,
                .friendship,
                .ethicalNonMono,
                .bdsm,
                .unicorn,
                .beAUnicorn,
                .joinAnEstablishedCouple
            ])
        ]
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
            
        case .professional: return R.string.localizable.expirienceProfessional()
        case .iveDoneItAll: return R.string.localizable.expirienceIveDoneItAll()
        case .veryExpirienced: return R.string.localizable.expirienceVeryExpirienced()
        case .upForAnything: return R.string.localizable.expirienceUpForAnything()
        case .somewhereInTheMiddle: return R.string.localizable.expirienceSomewhereInTheMiddle()
        case .alilBitOfThisNThat: return R.string.localizable.expirienceAlilBitOfThisNThat()
        case .newButReadyForAnything: return R.string.localizable.expirienceNewButReadyForAnything()
        case .curiousAndLooking: return R.string.localizable.expirienceCuriousAndLooking()
        case .vanilla: return R.string.localizable.expirienceVanilla()
        case .brandNew: return R.string.localizable.expirienceBrandNew()
            
        }
        
    }
    
}

extension User.Bio.PersonalQuestion {
    static let question1: String = R.string.localizable.personalQuestionQuestion1()
    static let question2: String = R.string.localizable.personalQuestionQuestion2()
    static let question3: String = R.string.localizable.personalQuestionQuestion3()
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
