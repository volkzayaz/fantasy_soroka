//
//  ProfilePhotoViewModel.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/5/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa

extension ProfilePhotoViewModel {
 
    var deleteButtonEnabled: Driver<Bool> {
        
        if isPublic && photoNumber == 0 {
            return .just(false)
        }
        
        return image.map { $0 != nil }
    }
    
    var image: Driver<UIImage?> {
        
        let i = photoNumber
        let isPublic = self.isPublic
        
        return appState.changesOf { $0.currentUser?.bio.photos }
            .map { photos -> Photo? in
                
                if !isPublic {
                    return photos?.private.images[safe: i]
                }
                
                if i == 0 {
                    return photos?.avatar
                }
                
                return photos?.public.images[safe: i - 1]
            }
            .flatMapLatest { (maybeURL) in
                
                guard let x = maybeURL?.url else { return .just(nil) }
                
                return ImageRetreiver.imageForURLWithoutProgress(url: x)
            }
        
    }
    
}

class ProfilePhotoViewModel : MVVM_ViewModel {
    
    let photoNumber: Int
    let isPublic: Bool
    
    init(router: ProfilePhotoRouter, number: Int, isPublic: Bool) {
        self.router = router
        self.photoNumber = number
        self.isPublic = isPublic
        
        /////progress indicator
        
        indicator.asDriver()
            .drive(onNext: { [weak h = router.owner] (loading) in
                h?.setLoadingStatus(loading)
            })
            .disposed(by: bag)
    }
    
    let router: ProfilePhotoRouter
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
    
}

extension ProfilePhotoViewModel {
    
    func pickPhoto() {
        
        FMPhotoImagePicker.present(on: router.container) { (image) in
        
            if self.isPublic && self.photoNumber == 0 {
                
                UserManager.replaceAvatar(image: image)
                    .trackView(viewIndicator: self.indicator)
                    .silentCatch(handler: self.router.container)
                    .subscribe(onNext: { (photo) in
                    
                        var u = User.current!
                        u.bio.photos.avatar = photo
                        
                        Dispatcher.dispatch(action: SetUser(user: u))
                        
                    })
                    .disposed(by: self.bag)
                
                return
            }
            
            UserManager.uploadPhoto(image: image, isPublic: self.isPublic)
                .trackView(viewIndicator: self.indicator)
                .silentCatch(handler: self.router.container)
                .subscribe(onNext: { (photo) in
                    
                    Dispatcher.dispatch(action: AddProfilePhoto(newPhoto: photo,
                                                                isPublic: self.isPublic))
                    
                })
                .disposed(by: self.bag)
            
        }
        
    }
    
    func deletePhoto() {
        
        var index = photoNumber
        if isPublic {
            index -= 1
        }
        
        Dispatcher.dispatch(action: RemoveProfilePhoto(byIndex: index, isPublic: self.isPublic))
        
    }
    
}
