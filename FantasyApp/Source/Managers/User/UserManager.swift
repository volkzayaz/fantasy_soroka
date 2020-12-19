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
        
        return save(user: updatedUser)
        
    }
    
    static func save(user: User) -> Single<User> {
        return user.toCurrentPFUser.rxSave()
            .map { _ in user }
    }
    
    static func replaceAvatar(image: UIImage) -> Single<Photo> {
        return UpdateUserAvatarResource(image: image).rx.request
            .map { avatar in
                
                let photo = Photo(id: "fake", url: avatar.avatar.absoluteString,
                                  thumbnailURL: avatar.avatarThumbnail.absoluteString)
                
                ImageRetreiver.registerImage(image: image, forKey: photo.url)
                ImageRetreiver.registerImage(image: image, forKey: photo.thumbnailURL)
                
                return photo
                
            }
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
    
    static func images(of user: UserProfile) -> Single<([Photo], [Photo])> {
        
        ///Server does not return Main avatar as part of the Album
        
        if let publicImages = user.publicAlbum?.images, let privateImages = user.privateAlbum?.images {
            let avatarPhoto = Photo(id: "", url: user.avatarURL, thumbnailURL: user.avatarThumbnailURL)
            return .just(([avatarPhoto] + publicImages, privateImages))
        }
        
        return GetImages(of: .user(user)).rx.request.map { photos in
            var `public` = photos.filter { !$0.isPrivate }.map { $0.toRegular }
            let `private` = photos.filter { $0.isPrivate }.map { $0.toRegular }
            
            let avatarPhoto = Photo(id: "", url: user.avatarURL, thumbnailURL: user.avatarThumbnailURL)
            `public`.insert(avatarPhoto, at: 0)
            
            return (`public`, `private`)
        }
    }
    
    static func deleteAccount() -> Single<Void> {
        
        return DeleteUser().rx.request
            .flatMap { _ in
                
                Single.create { (subscriber) in
                    
                    let user = PFUser(withoutDataWithObjectId: User.current!.id)
                    let notificationSettings = User.current!.notificationSettings.pfObject
                    
                    PFObject.deleteAll(inBackground: [user, notificationSettings]) { (res, error) in
                        
                        if let e = error {
                            subscriber(.error(e))
                        }
                        
                        subscriber( .success( () ) )
                        
                    }
                    
                    return Disposables.create()
                }
                
        }
        
    }    ///isSubscribed = 0;
    
    static func getUserProfile(id: String) -> Single<UserProfile?> {
        UserProfileResource(id: id).rx.request
            .map { !$0.isBlocked ? $0 : nil }
    }
    
}
