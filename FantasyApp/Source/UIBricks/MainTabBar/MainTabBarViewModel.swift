//
//  MainTabBarViewModel.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 7/27/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import Kingfisher

extension MainTabBarViewModel {
    
    var locationRequestHidden: Driver<Bool> {
        
        return Observable.combineLatest(SettingsStore.atLeastOnceLocation.observable,
                                        locationManager.rx.didChangeAuthorization) { ($0, $1) }
            .map { (didAskForLocation, authorizationStatus) in
                
                if authorizationStatus.status == .notDetermined { return true }
                
                guard didAskForLocation != nil else {
                    return SettingsStore.currentUser.value == nil
                }
                
                return (authorizationStatus.status != .denied)
            }
            .asDriver(onErrorJustReturn: false)
        
    }
 
    var profileTabImage: Driver<UIImage> {
        return appState.changesOf { $0.currentUser?.bio.photos.avatar.thumbnailURL ?? "" }
            .flatMapLatest { ImageRetreiver.imageForURLWithoutProgress(url: $0) }
            .map { $0 ?? R.image.noPhoto()! }
            .map { RoundCornerImageProcessor(cornerRadius: 15, targetSize: .init(width: 30, height: 30))
                .process(item: ImageProcessItem.image($0), options: [])! }
            .map { $0.withRenderingMode(.alwaysOriginal) }
    }
    
}

struct MainTabBarViewModel : MVVM_ViewModel {

    private let locationManager = CLLocationManager()
    
    init(router: MainTabBarRouter) {
        self.router = router
        
        ///Refresh on app start happens here:
        ///Alternativelly we can encode appState to disk and just restore it from there
        ///To keep syncing problems at min for now we'll fetch most info from server
        ///But for v2 we want to implement disk-first restoration policy
        Fantasy.Manager.fetchSwipesDeck()
            //.trackView(viewIndicator: indicator)
            .subscribe(onSuccess: { x in
                Dispatcher.dispatch(action: ResetSwipeDeck(deck: x))
            })
            .disposed(by: bag)

        locationManager.rx.didChangeAuthorization
            .filter { $0.status != .denied && $0.status != .notDetermined }
            .subscribe(onNext: { (_) in
                SettingsStore.atLeastOnceLocation.value = true
            })
            .disposed(by: bag)
        
        /////progress indicator
        
        indicator.asDriver()
            .drive(onNext: { [weak h = router.owner] (loading) in
                h?.setLoadingStatus(loading)
            })
            .disposed(by: bag)
        
        appState.changesOf { $0.inviteDeeplink }
            .notNil()
            .asObservable()
            .flatMap { [unowned i = indicator] x in
                RoomManager.assosiateSelfWith(roomRef: x.roomRef, password: x.password)
                    .trackView(viewIndicator: i)
            }
            .subscribe(onNext: { (room) in
                router.presentRoomSettings(room: room)
            })
            .disposed(by: bag)
        
    }
    
    let router: MainTabBarRouter
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
    
}

extension MainTabBarViewModel {
    
    /** Reference any actions ViewModel can handle
     ** Actions should always be void funcs
     ** any result should be reflected via corresponding drivers
     
     func buttonPressed(labelValue: String) {
     
     }
     
     */
    
}
