//
//  EditProfileForm.swift
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
    var relationshipStatus: RelationshipStatus??
    var pronoun: Pronoun??
    
    var lookingFor: [LookingFor]?
    
    ///each filed here is an Optional<T>. If value is not present in edit form, we will not apply it. Since |about| is an Optional<String> as well, we need String?? to represent editable String?
    var expirience: Expirience??
    var about: String??
    
    var publicPhotosAdded: [String]?
    var privatePhotosAdded: [String]?
    
    var publicPhotosRemoved: [String]?
    var privatePhotosRemoved: [String]?
    
    var communityChange: User.Community?
    
    var answers: User.Bio.PersonalQuestion
    var flirtAccess: Bool??
}

struct RegisterForm {
    var agreementTick: Bool = false
    var personalDataTick: Bool = false
    var sensetiveDataTick: Bool = false
    var agreeToEmailsTick: Bool = false
    
    var name: String = ""
    var brithdate: Date?
    var sexuality: Sexuality = .heteroflexible
    var gender: Gender = .female
    var lookingFor: [LookingFor] = []
    
    var email: String?
    var password: String?
    var confirmPassword: String?

    var selectedPhoto: SelectedPhoto?
    var photo: UIImage?
    
    struct SelectedPhoto {
        let image: UIImage
        let source: Analytics.Event.SignUpPassed.PhotoSource
    }
    
    var toEditProfileForm: EditProfileForm {
        return EditProfileForm(name: name,
                               brithdate: brithdate,
                               sexuality: sexuality,
                               gender: gender,
                               relationshipStatus: nil,
                               lookingFor: lookingFor,
                               expirience: nil,
                               about: nil,
                               publicPhotosAdded: [],
                               privatePhotosAdded: [],
                               publicPhotosRemoved: [],
                               privatePhotosRemoved: [],
                               communityChange: User.Community(value: nil,
                                                               changePolicy: .locationBased),
                               answers: [:]
                               )
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
        applicator(lhs: &bio.pronoun, rhs: editForm.pronoun)
        applicator(lhs: &bio.lookingFor, rhs: editForm.lookingFor)
        applicator(lhs: &bio.expirience, rhs: editForm.expirience)
        applicator(lhs: &bio.about, rhs: editForm.about)
        applicator(lhs: &community, rhs: editForm.communityChange)
        applicator(lhs: &bio.answers, rhs: editForm.answers)
        applicator(lhs: &bio.flirtAccess, rhs: editForm.flirtAccess)
    }
    
}