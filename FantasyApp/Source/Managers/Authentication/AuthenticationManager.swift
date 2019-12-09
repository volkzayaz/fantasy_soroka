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

enum AuthenticationManager {}
extension AuthenticationManager {
    
    static func register(with form: RegisterForm) -> Single<User> {
        
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
        ///
        
        let pfUser = PFUser()

        pfUser.username = form.email
        pfUser.email = form.email
        pfUser.password = form.password
        
        pfUser.apply(editForm: form.toEditProfileForm)
        
        let x: Observable<PFUser> = Observable.create { (subscriber) -> Disposable in
            
            pfUser.signUpInBackground(block: { (didSignUp, maybeError) in
                
                if let e = maybeError {
                    return subscriber.onError(e)
                }
                
                subscriber.onNext( pfUser )
                subscriber.onCompleted()
                
            })
            
            return Disposables.create()
        }
        .flatMap { (u: PFUser) -> Single<PFUser> in
            return UpdateUserAvatarResource(image: form.photo!).rx.request
                .map { avatar -> PFUser in
                    u["avatar"] = avatar.avatar.absoluteString
                    u["avatarThumbnail"] = avatar.avatarThumbnail.absoluteString
                    
                    return u
            }
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
            .map { $0 == nil }
        
    }
    
    static func currentUser() -> User? {
        return SettingsStore.currentUser.value
    }
    
    static func logout() {
        SettingsStore.currentUser.value = nil
        PFUser.logOutInBackground(block: { _ in })
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
