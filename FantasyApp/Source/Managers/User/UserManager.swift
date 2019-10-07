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
    
    static func uploadPhoto(image: UIImage, isPublic: Bool) -> Single<Photo> {
        
        let photos = User.current!.bio.photos
        
        let album = isPublic ? photos.public : photos.private
        
        return UploadAlbumImage(image: image, album: album).rx.request.map { album in
            
            let photo = album.images.last!
        
            ImageRetreiver.registerImage(image: image, forKey: photo.url)
            
            return photo
        }
        
    }
    
    static func dropPhoto(fromAlbum: Album, index: Int) -> Single<Void> {
        
        return DeletePhoto(fromAlbum: fromAlbum, photo: fromAlbum.images[index])
            .rx.request
            .map { _ in }
            
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
    
    static func images(of user: User) -> Single<([Photo], [Photo])> {
        
        ///Server does not return Main avatar as part of the Album
        
        return GetImages(of: .user(user)).rx.request.map { photos in
            
            var `public` = photos.filter { !$0.isPrivate }
                                 .map { $0.toRegular }
            
            if let p = user.bio.photos.main {
                `public` = [p] + `public`
            }
            
            let `private` = photos.filter { $0.isPrivate }
                                  .map { $0.toRegular }
            
            return (`public`, `private`)
        }
    }
    
}
