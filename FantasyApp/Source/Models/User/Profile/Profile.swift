//
//  Profile.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/2/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

struct EditProfileForm {
    
    var name: String? = nil
    var brithdate: Date?
    var sexuality: Sexuality?
    var gender: Gender?
    var relationshipStatus: RelationshipStatus?
    
    var publicPhotosAdded: [String]?
    var privatePhotosAdded: [String]?
    
    var publicPhotosRemoved: [String]?
    var privatePhotosRemoved: [String]?
    
}

struct RegisterForm {
    var agreementTick: Bool = false
    
    var name: String = ""
    var brithdate: Date?
    var sexuality: Sexuality = .straight
    var gender: Gender = .female
    var relationshipStatus: RelationshipStatus?
    
    var email: String?
    var password: String?
    var confirmPassword: String?
    
    var photo: UIImage?
    
    var toEditProfileForm: EditProfileForm {
        return .init(name: name, brithdate: brithdate, sexuality: sexuality, gender: gender, relationshipStatus: relationshipStatus, publicPhotosAdded: [], privatePhotosAdded: [], publicPhotosRemoved: [], privatePhotosRemoved: [])
    }
    
};


extension User {
    
    func applied(editForm: EditProfileForm) -> User {
        var x = self
        x.apply(editForm: editForm)
        return x
    }
    
    mutating func apply(editForm: EditProfileForm) {
        
        func applicator<T>( lhs: inout T, rhs: T?) {
            guard let x = rhs else { return }
            
            lhs = x
        }
        
        applicator(lhs: &bio.name, rhs: editForm.name)
        applicator(lhs: &bio.birthday, rhs: editForm.brithdate)
        applicator(lhs: &bio.relationshipStatus, rhs: editForm.relationshipStatus)
        applicator(lhs: &bio.gender, rhs: editForm.gender)
        applicator(lhs: &bio.sexuality, rhs: editForm.sexuality)
        
    }
    
}
