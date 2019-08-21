//
//  User+Parse.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 7/28/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

enum ParseMigrationError: Error {
    case dataCorrupted
}

extension User {
    
    ///single migration point from Parse Entity to Fantasy Entity
    init(pfUser: PFUser) throws {
        
        if let x = pfUser.email {
            auth = .email(x)
        }
        else if let x = pfUser.value(forKey: "authData") as? [String: Any] {
            auth = .fbData(x.description)
        }
        else { throw ParseMigrationError.dataCorrupted }
    
        guard let name = pfUser["realname"] as? String else {
            throw ParseMigrationError.dataCorrupted
        }
        
        guard let birthday = pfUser["birthday"] as? Date else {
            throw ParseMigrationError.dataCorrupted
        }
        
        guard let genderString = pfUser["gender"] as? String,
              let gender = Gender(rawValue: genderString) else {
            throw ParseMigrationError.dataCorrupted
        }
        
        guard let sexualityString = pfUser["sexuality"] as? String,
              let sexuality = Sexuality(rawValue: sexualityString) else {
            throw ParseMigrationError.dataCorrupted
        }
        
        let relationStatus: RelationshipStatus
        if let x = pfUser["couple"] as? String {
            
            if let gender = Gender(rawValue: x) { relationStatus = .couple(partnerGender: gender) }
            else                                { relationStatus = .single }
            
        } else {
            ///applying default value policy
            relationStatus = .single
        }
        
        
        bio = Bio(name: name,
                  birthday: birthday,
                  gender: gender,
                  sexuality: sexuality,
                  relationshipStatus: relationStatus,
                  photos: .init(public: [], private: []))
        
        preferences = .init(lookingFor: [],
                            kinks: [])
        fantasies = .init(liked: [], disliked: [], purchasedCollections: [])
        community = .init()
        connections = .init(likeRequests: [], chatRequests: [], rooms: [])
        privacy = .init(privateMode: false, disabledMode: false, blockedList: [])
        
    }
    
}
