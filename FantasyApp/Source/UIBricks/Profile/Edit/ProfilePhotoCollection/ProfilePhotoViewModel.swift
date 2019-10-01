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
 
    var deleteButtonHidden: Driver<Bool> {
        return image.map { $0 == nil }
    }
    
    var image: Driver<UIImage?> {
        
        let i = photoNumber
        let isPublic = self.isPublic
        
        return appState.changesOf { $0.currentUser?.bio.photos }
            .map { isPublic ? $0?.public.images[safe: i] : $0?.private.images[safe: i] }
            .flatMapLatest { (maybeURL) in
                
                guard let x = maybeURL?.url else { return .just(nil) }
                
                return ImageRetreiver.imageForURLWithoutProgress(url: x)
            }
        
    }
    
}

struct ProfilePhotoViewModel : MVVM_ViewModel {
    
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
        
        FDTakeImagePicker.present(on: router.container) { (image) in
            
            UserManager.uploadPhoto(image: image, isPublic: self.isPublic)
                .trackView(viewIndicator: self.indicator)
                .silentCatch(handler: self.router.container)
                .subscribe(onNext: { (newURL) in
                    
                    Dispatcher.dispatch(action: AddProfilePhoto(newPhoto: newURL,
                                                                isPublic: self.isPublic))
                    
                })
                .disposed(by: self.bag)
            
        }
        
    }
    
    func deletePhoto() {
        
        Dispatcher.dispatch(action: RemoveProfilePhoto(byIndex: photoNumber, isPublic: self.isPublic))
        
        let _ = UserManager.dropPhoto(index: photoNumber, isPublic: self.isPublic)
            .subscribe()
        
    }
    
}
