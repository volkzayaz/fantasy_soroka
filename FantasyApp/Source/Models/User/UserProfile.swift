//
//  UserProfile.swift
//  FantasyApp
//
//  Created by Ihor Vovk on 08.12.2020.
//  Copyright © 2020 Fantasy App. All rights reserved.
//

import Foundation

struct UserProfile: Decodable, Hashable, UserIdentifier {
    
    struct Community: Decodable, Hashable {
        let id: String
        let name: String
        let country: String?
        
        init?(_ community: FantasyApp.Community) {
            guard let id = community.objectId else { return nil }
            
            self.id = id
            name = community.name
            country = community.country
        }
    }
    
    let id: String
    let name: String
    let gender: Gender
    let sexuality: Sexuality
    let pronoun: Pronoun?
    let age: Int
    let about: String?
    let relationshipStatus: RelationshipStatus?
    let avatarURL: String
    let avatarThumbnailURL: String
    let experience: Expirience?
    let lookingFor: [LookingFor]
    var answers: [String: String]
    var community: Community?
    
    let isBlocked: Bool
    let isSubscribed: Bool
    let isViewed: Bool?
    let registrationDate: Date
    
    var publicAlbum: Album?
    var privateAlbum: Album?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    init(user: User) {
        id = user.id
        name = user.bio.name
        gender = user.bio.gender
        sexuality = user.bio.sexuality
        pronoun = user.bio.pronoun
        age = user.bio.birthday.distance(from: Date(), in: .year)
        about = user.bio.about
        relationshipStatus = user.bio.relationshipStatus
        avatarURL = user.bio.photos.avatar.url
        avatarThumbnailURL = user.bio.photos.avatar.thumbnailURL
        experience = user.bio.expirience
        lookingFor = user.bio.lookingFor
        answers = user.bio.answers
        community = user.community.value.map { Community($0) } ?? nil
        isBlocked = false
        isSubscribed = user.subscription.isSubscribed
        isViewed = nil
        publicAlbum = user.bio.photos.public
        privateAlbum = user.bio.photos.private
        registrationDate = user.bio.registrationDate
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name = "realname"
        case gender
        case sexuality
        case pronoun
        case age
        case about = "aboutMe"
        case relationshipType = "myRelationshipStatus"
        case partnerGender = "myPartnerGender"
        case avatarURL = "avatar"
        case avatarThumbnailURL = "avatarThumbnail"
        case experience = "expirience"
        case lookingFor
        case answers
        case community
        case isBlocked
        case isSubscribed
        case isViewed
        case registrationDate = "createdAt"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        gender = try container.decode(Gender.self, forKey: .gender)
        sexuality = try container.decode(Sexuality.self, forKey: .sexuality)
        pronoun = try? container.decode(Pronoun.self, forKey: .pronoun)
        age = try container.decode(Int.self , forKey: .age)
        about = try? container.decode(String.self, forKey: .about)
        
        if let relationshipType = try? container.decode(RelationshipType.self, forKey: .relationshipType) {
            let partnerGender = try? container.decode(Gender.self, forKey: .partnerGender)
            relationshipStatus = RelationshipStatus(relationshipType: relationshipType, partnerGender: partnerGender)
        } else {
            relationshipStatus = nil
        }
        
        avatarURL = try container.decode(String.self, forKey: .avatarURL)
        avatarThumbnailURL = try container.decode(String.self, forKey: .avatarThumbnailURL)
        experience = try? container.decode(Expirience.self, forKey: .experience)
        lookingFor = (try? container.decode([LookingFor].self, forKey: .lookingFor)) ?? []
        answers = (try? container.decode([String: String].self, forKey: .answers)) ?? [:]
        community = try? container.decode(Community.self, forKey: .community)
        isBlocked = (try? container.decode(Bool.self, forKey: .isBlocked)) ?? false
        isSubscribed = (try? container.decode(Bool.self, forKey: .isSubscribed)) ?? false
        isViewed = try? container.decode(Bool.self, forKey: .isViewed)
        registrationDate = try container.decode(Date.self, forKey: .registrationDate)
    }
}
