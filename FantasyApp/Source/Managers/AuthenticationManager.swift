//
//  AuthenticationManager.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 7/27/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift

import Parse

enum AuthenticationManager {}
extension AuthenticationManager {
    
    static func register(with form: RegistrationViewModel.SubmissionForm) -> Maybe<User> {
        
        let form = RegistrationViewModel.SubmissionForm(agreementTick: true,
                                                        name: "Pete Jackson",
                                                        brithdate: Date(timeIntervalSince1970: 1234),
                                                        sexuality: .straight,
                                                        gender: .male,
                                                        relationshipStatus: .single,
                                                        email: "pete@jackson.com",
                                                        password: "1234", confirmPassword: "",
                                                        photo: nil)
        
        ///
        
        let pfUser = PFUser()
        
        pfUser.username = form.email
        pfUser.email = form.email
        pfUser.password = form.password
        
        pfUser["realname"] = form.name
        pfUser["birthday"] = form.brithdate
        
        switch form.relationshipStatus! {
        case .single:                       pfUser["couple"] = "single"
        case .couple(let partnerGender):    pfUser["couple"] = partnerGender.rawValue
        }
        
        pfUser["gender"] = form.gender.rawValue
        pfUser["sexuality"] = form.sexuality.rawValue
        
        //fatalError("Implement picked photo uploading")
        
        return Observable.create { (subscriber) -> Disposable in
            
            pfUser.signUpInBackground(block: { (didSignUp, maybeError) in
                
                if let e = maybeError {
                    return subscriber.onError(e)
                }
                
                subscriber.onNext( pfUser )
                subscriber.onCompleted()
                
            })
            
            return Disposables.create()
        }
            .map { try User(pfUser: $0) }
            .asMaybe()
        
    }
    
    static func login(with email: String, password: String) -> Maybe<User> {
        
        return Observable.create { (subscriber) -> Disposable in
            
                PFUser.logInWithUsername(inBackground: email, password: password) { (maybeUser, maybeError) in
                    if let e = maybeError {
                        return subscriber.onError(e)
                    }
                
                    subscriber.onNext( maybeUser! )
                    subscriber.onCompleted()
                }
            
                return Disposables.create()
            }
            .map { try User(pfUser: $0) }
            .asMaybe()
        
    }
    
    static func loginWithFacebook() -> Maybe<User> {
        
        return Observable.create { (subscriber) -> Disposable in
            
            let permissions = ["public_profile", "email", "user_photos", "user_birthday"]
            
            PFFacebookUtils.logInInBackground(withReadPermissions: permissions) { (maybeUser, maybeError) in
                
                if let e = maybeError {
                    return subscriber.onError(e)
                }
                
                if maybeUser?.isNew ?? false {
                    return subscriber.onError( FantasyError.generic(description: R.string.localizable.authorizationNewFBUser()) )
                }
                
                subscriber.onNext( maybeUser! )
                subscriber.onCompleted()
                
            }
                        
            return Disposables.create()
            }
            .map { try User(pfUser: $0) }
            .asMaybe()
        
    }
 
    static func currentUser() -> User? {
        
        var user: User? = nil
        if let pfUser = PFUser.current() {
            user = try? User(pfUser: pfUser)
        }
        
        return user
    }
    
    static func logout() {
        PFUser.logOutInBackground(block: { _ in })
    }
    
}
