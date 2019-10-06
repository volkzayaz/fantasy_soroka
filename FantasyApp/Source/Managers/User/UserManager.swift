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
        
        let updatedUser = User.current!.applied(editForm: form)
        
        return updatedUser.toCurrentPFUser.rxSave()
            .map { _ in updatedUser }
        
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
    
    static func fetchOrCreateAlbums() -> Single<(public: Album, private: Album)> {
        return GetAlbums(of: .me).rx.request
            .flatMap { albums in
                
                guard albums.count == 2,
                    let publicAlbum  = albums.filter({ !$0.isPrivate }).first,
                    let privateAlbum = albums.filter({  $0.isPrivate }).first else {
                    fatalError("Can't continue without one public and one private album. Received: \(albums)")
                }
                
                return Single.zip(GetAlbumContent(album: publicAlbum ).rx.request,
                                  GetAlbumContent(album: privateAlbum).rx.request)
                    .map { (public: $0, private: $1) }
                
            }
    }
    
    static func images(of user: User) -> Single<[Photo]> {
        
        ///Server does not return Main avatar as part of the Album
        
        return GetImages(of: .user(user)).rx.request.map { photos in
            
            if let p = user.bio.photos.main {
                return [p] + photos
            }
            
            return photos
        }
    }
    
}
