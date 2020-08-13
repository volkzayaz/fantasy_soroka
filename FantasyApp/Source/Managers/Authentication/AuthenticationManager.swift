//
//  AuthenticationManager.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 7/27/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift
import Branch
import Parse
import Amplitude_iOS

enum AuthenticationManager {}
extension AuthenticationManager {
    
    static private let temporaryPassword = "FantasyMatch"
    
    // Registration is performed in 2 steps: registerIncomplete and finishRegistration. First should be called after email is entered. On this step the temporary password is used. It is for cases like when a user removes the app before completing registration, or uses another device to finish registration with the same email. In such cases they may use different password later. So, we update the password on the last step after finishing registration. Parse will have profileStatus field with corresponding values for users passed registration steps: incompleteSignUp and active.
    static func registerIncomplete(with form: RegisterForm) -> Single<PFUser> {
        guard let email = form.email else {
            return .error(FantasyError.generic(description: "Missing email"))
        }
        
        return Observable<PFUser>.create { subscriber -> Disposable in
            if let pfUser = PFUser.current(), pfUser.username == form.email {
                subscriber.onNext( pfUser )
                subscriber.onCompleted()
            } else {
                PFUser.logInWithUsername(inBackground: email, password: temporaryPassword) { (maybeUser, maybeError) in
                    if let _ = maybeError {
                        let pfUser = PFUser()
                        pfUser.username = email
                        pfUser.email = email
                        pfUser.password = temporaryPassword
                        pfUser.profileStatus = .incompleteSignUp
                        
                        pfUser.signUpInBackground(block: { (didSignUp, maybeError) in
                            if let e = maybeError {
                                return subscriber.onError(e)
                            }
                            
                            subscriber.onNext( pfUser )
                            subscriber.onCompleted()
                        })
                    } else {
                        subscriber.onNext( maybeUser! )
                        subscriber.onCompleted()
                    }
                }
            }
            
            return Disposables.create()
        }.flatMap { pfUser in
            MarkUserSignUp().rx.request.map { _ in pfUser }
        }.do(onNext: { pfUser in
            if let userID = pfUser.objectId {
                Amplitude.instance()?.setUserId(userID)
            }
        }).asSingle()
    }
    
    static func finishRegistration(with form: RegisterForm) -> Single<User> {
        
//        let form = RegisterForm(agreementTick: true,
//                                name: "Pete3 Jackson",
//                                brithdate: Date(timeIntervalSince1970: 1234),
//                                sexuality: .straight,
//                                gender: .male,
//                                relationshipStatus: .single,
//                                email: "pete3@jackson.com",
//                                password: "1234", confirmPassword: "",
//                                photo: form.photo)
//
        guard let pfUser = PFUser.current() else {
            return .error(FantasyError.generic(description: "Sign Up failure. User was not created."))
        }
        
        pfUser.apply(editForm: form.toEditProfileForm)
        pfUser.profileStatus = .active
        
        let x: Observable<PFUser> = Observable.create { (subscriber) -> Disposable in
            
            pfUser.saveInBackground { (didSave, maybeError) in
                if let e = maybeError {
                    return subscriber.onError(e)
                }
                
                subscriber.onNext( pfUser )
                subscriber.onCompleted()
            }
            
            return Disposables.create()
        }
        .flatMap { (u: PFUser) -> Single<PFUser> in
            return UserManager.replaceAvatar(image: form.photo!)
                .map { avatar -> PFUser in
                    u["avatar"] = avatar.url
                    u["avatarThumbnail"] = avatar.thumbnailURL
                    
                    return u
            }
        }
        .flatMap { u in
            return MarkUserSignUp().rx.request.map { _ in u }
        }

        return postAuthorizationParseMess(signal: x)
        
    }

    static func requestPassword(with email: String) -> Single<Bool> {

        let x: Observable<Bool> = Observable.create { (subscriber) -> Disposable in

            PFUser.requestPasswordResetForEmail(inBackground: email) { (res, maybeError) in

                if let e = maybeError {
                    return subscriber.onError(e)
                }

                subscriber.onNext(true)
                subscriber.onCompleted()

            }
            return Disposables.create()
        }

        return x.asSingle()
    }
    
    static func login(with email: String, password: String) -> Single<User> {
        
        let x: Observable<PFUser> = Observable.create { (subscriber) -> Disposable in
            
                PFUser.logInWithUsername(inBackground: email, password: password) { (maybeUser, maybeError) in
                    if let e = maybeError {
                        return subscriber.onError(e)
                    }
                    
                    subscriber.onNext( maybeUser! )
                    subscriber.onCompleted()
                    
                }
            
                return Disposables.create()
            }
            
        return postAuthorizationParseMess(signal: x)
        
    }
    
    static func loginWithFacebook() -> Single<User> {
        
        let x: Observable<PFUser> = Observable.create { (subscriber) -> Disposable in
            
            let permissions = ["public_profile", "email", "user_photos"]

            PFFacebookUtils.facebookLoginManager().logOut()
            PFFacebookUtils.logInInBackground(withReadPermissions: permissions) { (maybeUser, maybeError) in
                
                if let e = maybeError {
                    return subscriber.onError(e)
                }
                
                if maybeUser?.isNew ?? false {
                    return subscriber.onError( FantasyError.generic(description: R.string.localizable.authorizationNewFBUser()) )
                }
                
                if maybeUser == nil && maybeError == nil {
                    subscriber.onError( FantasyError.canceled )
                    return
                }
                
                subscriber.onNext( maybeUser! )
                subscriber.onCompleted()
                
            }
                        
            return Disposables.create()
        }
            
        return postAuthorizationParseMess(signal: x)
    }
 
    static func isUnique(email: String)-> Single<Bool> {
        return User.query
            .whereKey("email", equalTo: email)
            .rx.fetchFirstObject()
            .map { $0 == nil || ($0 as? PFUser)?.profileStatus == PFUser.ProfileStatus.incompleteSignUp }
    }
    
    static func currentUser() -> User? {
        return SettingsStore.currentUser.value
    }
    
    static func logout() {
        SettingsStore.currentUser.value = nil
        PFUser.logOut()
    }

    private static func postAuthorizationParseMess( signal: Observable<PFUser> ) -> Single<User> {
        
        return signal
            .asSingle()
            .flatMap { (u: PFUser) -> Single<User> in
                return u.convertWithAlbumsAndSubscriptionAndNotificationSettings()
            }
            .do(onSuccess: { (user) in
                SettingsStore.currentUser.value = user
            })
        
    }
    
}
