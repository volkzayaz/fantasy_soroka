//
//  User+Parse.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 7/28/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift

enum ParseMigrationError: Error {
    case dataCorrupted
}


extension User {
    
    ///single migration point from Parse Entity to Fantasy Entity
    init(pfUser: PFUser,
         albums: (public: Album, private: Album)? = nil,
         subscriptionStatus: User.Subscription? = nil,
         notifSettings: NotificationSettings? = nil) throws {

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
              let gender = Gender(fromFantasyRawValue: genderString) else {
            throw ParseMigrationError.dataCorrupted
        }
        
        guard let sexualityString = pfUser["sexuality"] as? String,
              let sexuality = Sexuality(fromFantasyRawValue: sexualityString) else {
            throw ParseMigrationError.dataCorrupted
        }
        
        guard let photoURL = pfUser["avatar"] as? String,
              let thumbnailURL = pfUser["avatarThumbnail"] as? String else {
            throw ParseMigrationError.dataCorrupted
        }
        let mainPhoto = Photo(id: "fake", url: photoURL, thumbnailURL: thumbnailURL)
        
        let relationStatus: RelationshipStatus
        if let x = pfUser["couple"] as? String {
            
            if let gender = Gender(fromFantasyRawValue: x) { relationStatus = .couple(partnerGender: gender) }
            else                                { relationStatus = .single }
            
        } else {
            ///applying default value policy
            relationStatus = .single
        }
        
        let changePolicy: User.CommunityChangePolicy
        if let index = (pfUser["communityChangePolicy"] as? Int) {
            changePolicy = User.CommunityChangePolicy(rawValue: index) ?? .locationBased
        }
        else {
            changePolicy = .locationBased
        }
        
        let maybeCommunity: FantasyApp.Community? = (pfUser["belongsTo"] as? PFObject)?.toCodable()
        var maybeLastKnownLocation: User.LastKnownLocation? = nil
        if let x = pfUser["lastKnownLocation"] as? PFGeoPoint {
            maybeLastKnownLocation = .init(pfGeoPoint: x)
        }
        
        let photos = User.Bio.Photos(avatar  : mainPhoto,
                                     public  : albums?.public  ?? .init(images: []) ,
                                     private : albums?.private ?? .init(images: []))
        
        var maybeLookingFor: [LookingFor] = []
        if let string = pfUser["lookingForV2"] as? String {
            
            maybeLookingFor = string.components(separatedBy: ", ")
                                    .compactMap({ Int($0) })
                                    .compactMap ({ LookingFor(rawValue: $0) })
            
        }
        
        var maybeExpirience: Expirience? = nil
        if let int = pfUser["expirience"] as? Int {
            maybeExpirience = Expirience(rawValue: int)
        }
        
        let answers = pfUser["answers"] as? Bio.PersonalQuestion ?? [:]
        
        var subscriptionObject: Subscription? = subscriptionStatus
        if subscriptionObject == nil,
           let isSubscribed = pfUser["isSubscribed"] as? Bool,
           isSubscribed == true {
            
            ///new server subscription API stores isSubscribed flag into User collection
            ///it hasn't similar mapping to proper subscription status
            ///so before we moved away from Parse.User, we will manually conform
            ///isSubscribed: Bool to User.Subscription
            ///it will not be precise, but should fit our business needs
            
            subscriptionObject = .init(status: .init(endDate: Date.distantFuture))
            
        }
        
        var searchPrefs: SearchPreferences? = nil
        if let x = pfUser["searchPrefs"] as? Data,
           let s = try? JSONDecoder().decode(SearchPreferences.self, from: x) {
            searchPrefs = s
        }
        
        let flirtAccess = (pfUser["flirtAccess"] as? Bool) ?? true
        
        id = objectId
        bio = User.Bio(registrationDate: pfUser.createdAt!,
                       name: name,
                       about: about,
                       birthday: birthday,
                       gender: gender,
                       sexuality: sexuality,
                       relationshipStatus: relationStatus,
                       photos: photos,
                       lookingFor: maybeLookingFor,
                       expirience: maybeExpirience,
                       answers: answers,
                       flirtAccess: flirtAccess)
        
        searchPreferences = searchPrefs
        fantasies = .init(purchasedCollections: [])
        community = User.Community(value: maybeCommunity,
                                   changePolicy: changePolicy,
                                   lastKnownLocation: maybeLastKnownLocation)
        subscription = subscriptionObject ?? .init(status: nil)
        notificationSettings = notifSettings ?? NotificationSettings()
    }
    
    ////we can edit only a subset of exisitng user properties to Parse
    ////we apply reverse transformations from init
    ////In the future on our backend it is expected that User consists fully from editable properties.
    var toCurrentPFUser: PFUser {
        
        guard let user = PFUser.current() else { fatalError("No current user exist, can't convert native user") }
        
        let lookingForV2: String = bio.lookingFor.map { "\($0.rawValue)" }.joined(separator: ", ")
        var searchPrefs: Data? = nil
        if let x = searchPreferences {
            searchPrefs = try! JSONEncoder().encode(x)
        }
        
        var dict = [
            "realname"                  : bio.name,
            "aboutMe"                   : bio.about as Any,
            "birthady"                  : bio.birthday,
            "gender"                    : bio.gender.rawValue,
            "sexuality"                 : bio.sexuality.rawValue,
            "lookingForV2"              : lookingForV2 as Any,
            "expirience"                : bio.expirience?.rawValue as Any,
            "answers"                   : bio.answers,
            "flirtAccess"               : bio.flirtAccess as? Any,
            "couple"                    : bio.relationshipStatus.parseField,
            
            "searchPrefs"               : searchPrefs as Any,
            
            "belongsTo"                 : community.value?.pfObject as Any,
            "communityChangePolicy"     : community.changePolicy.rawValue,
            "lastKnownLocation"         : community.lastKnownLocation?.pfGeoPoint as Any,
            
            "notificationSettings"      : notificationSettings.pfObject,
        ] as [String : Any]
        
        user.setValuesForKeys(dict)
        
        return user
    }
}

extension PFUser {
    
    enum ProfileStatus: String {
        case incompleteSignUp
        case active
    }
    
    var profileStatus: ProfileStatus? {
        get {
            (self["profileStatus"] as? String).flatMap { ProfileStatus(rawValue: $0) }
        }
        
        set {
            self["profileStatus"] = newValue?.rawValue
        }
    }
    
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
        setter("flirtAccess", false)
        
    }
 
    func convertWithAlbumsAndSubscriptionAndNotificationSettings() -> Single<User> {
        
        guard self == PFUser.current() else {
            fatalError("Method is only designed to be used for currentUser")
        }
        
        ///Fetch or create notification settings
        let notificationSettingsSignal: Single<NotificationSettings>
        if let x = (self["notificationSettings"] as? PFObject) {
            notificationSettingsSignal = x.rx.fetch().map { $0.toCodable() }
        }
        else {
            notificationSettingsSignal = NotificationSettings().rxCreate()
        }
        
        return Single.zip(UserManager.fetchOrCreateAlbums(),
                          PurchaseManager.fetchSubscriptionStatus(),
                          (self["belongsTo"] as? PFObject)?.rx.fetch() ?? .just( PFUser() ),
                          notificationSettingsSignal
                          )
            .map { (arg) -> User in
                
                var (albums, subscripiton, _, ns) = arg
                
                let luckyboys = ["lord@colgate.com",
                                 "mr@voldemort.com",
                                 "samuel@hagrid.com",
                                 "harry@stalone.com",
                                 "glorious@gandalf.com"]
                
                if luckyboys.contains(self.email ?? "") {
                    subscripiton = .init(status: .init(endDate: Date.distantFuture))
                }
                
                return try User(pfUser: self,
                                albums: albums,
                                subscriptionStatus: subscripiton,
                                notifSettings: ns)
            }
            
    }
    
}
