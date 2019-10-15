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
            
        return postAuthorizationParseMess(signal: x)
    }
 
    static func currentUser() -> User? {
        return SettingsStore.currentUser.value
    }
    
    static func logout() {
        SettingsStore.currentUser.value = nil
        SettingsStore.atLeastOnceLocation.value = nil
        PFUser.logOutInBackground(block: { _ in })
        Branch.getInstance()?.logout()
    }

    private static func postAuthorizationParseMess( signal: Observable<PFUser> ) -> Single<User> {
        
        return signal
            .asSingle()
            .flatMap { (u: PFUser) -> Single<User> in
                return u.convertWithAlbumsAndSubscriptionAndNotificationSettings()
            }
            .do(onSuccess: { (user) in
                SettingsStore.currentUser.value = user
                Branch.getInstance()?.setIdentity(user.id)
            })
        
    }
    
}
