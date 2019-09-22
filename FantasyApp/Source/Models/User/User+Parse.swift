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

        guard let objectId = pfUser.objectId else {
            fatalError("Unsaved PFUsers conversion to native User is not supported")
        }
        
//        if let x = pfUser.email {
//            auth = .email(x)
//        }
//        else if let x = pfUser.value(forKey: "authData") as? [String: Any] {
//            auth = .fbData(x.description)
//        }
//        else { throw ParseMigrationError.dataCorrupted }
    
        guard let name = pfUser["realname"] as? String else {
            throw ParseMigrationError.dataCorrupted
        }
        
        let about = pfUser["aboutMe"] as? String
        
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
        
        var changePolicy = User.CommunityChangePolicy.locationBased
        if let index = (pfUser["communityChangePolicy"] as? Int) {
            changePolicy = User.CommunityChangePolicy(rawValue: index) ?? .locationBased
        }
        
        let maybeCommunity: FantasyApp.Community? = (pfUser["belongsTo"] as? PFObject)?.toCodable()
        
        id = objectId
        bio = .init(name: name,
                    about: about,
                    birthday: birthday,
                    gender: gender,
                    sexuality: sexuality,
                    relationshipStatus: relationStatus,
                    photos: .init(public: [], private: []))
        
        ///TODO: save on server
        searchPreferences = nil
        fantasies = .init(liked: [], disliked: [], purchasedCollections: [])
        community = User.Community(value: maybeCommunity, changePolicy: changePolicy)
        connections = .init(likeRequests: [], chatRequests: [], rooms: [])
        //privacy = .init(privateMode: false, disabledMode: false, blockedList: [])
        
    }
    
    ////we can edit only a subset of exisitng user properties to Parse
    ////we apply reverse transformations from init
    ////In the future on our backend it is expected that User consists fully from editable properties.
    var toCurrentPFUser: PFUser {
        
        guard let user = PFUser.current() else { fatalError("No current user exist, can't convert native user") }
        
        var dict = [
            "realname"              : bio.name,
            "aboutMe"               : bio.about as Any,
            "birthady"              : bio.birthday,
            "gender"                : bio.gender.rawValue,
            "sexuality"             : bio.sexuality.rawValue,
            "belongsTo"             : community.value?.pfObject as Any,
            "communityChangePolicy" : community.changePolicy.rawValue
            ] as [String : Any]
        
        switch bio.relationshipStatus {
        case .single:                    dict["couple"] = "single"
        case .couple(let partnerGender): dict["couple"] = partnerGender
        }
        
        user.setValuesForKeys(dict)
        
        return user
    }
}

extension PFUser {
    
    func apply(editForm: EditProfileForm) {
        
        let setter: (String, Any?) -> () = { key, maybeValue in
            
            if let x = maybeValue {
                self[key] = x
            }
            
        }

        setter("realname", editForm.name)
        setter("birthday", editForm.brithdate)
        
        switch editForm.relationshipStatus {
        case .single?:                    setter("couple", "single")
        case .couple(let partnerGender)?: setter("couple", partnerGender.rawValue)
        case .none: break
        }
        
        setter("gender", editForm.gender?.rawValue)
        setter("sexuality", editForm.sexuality?.rawValue)
        
    }
    
}
