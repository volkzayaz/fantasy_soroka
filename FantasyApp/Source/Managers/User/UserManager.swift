//
//  UserManager.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/5/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift

enum UserManager {}

extension UserManager {

    static func submitEdits(form: EditProfileForm) -> Single<User> {
        
        ///TODO: implement network edit
        
        let updatedUser = User.current!.applied(editForm: form)
        
        return .just(updatedUser)
        
    }
    
    static func uploadPhoto(image: UIImage, isPublic: Bool) -> Single<String> {
        
        ///TODO: implement network upload
        
        let fakeURL = UUID().uuidString
        ImageRetreiver.registerImage(image: image, forKey: fakeURL)
        
        return Observable.just(fakeURL)
            .delay(.seconds(1), scheduler: MainScheduler.instance)
            .asSingle()
        
    }
    
    static func dropPhoto(index: Int, isPublic: Bool) -> Single<Void> {
        
        ///TODO: implement network upload
        
        return Observable.just( () )
            .delay(.seconds(3), scheduler: MainScheduler.instance)
            .asSingle()
        
    }
    
}
