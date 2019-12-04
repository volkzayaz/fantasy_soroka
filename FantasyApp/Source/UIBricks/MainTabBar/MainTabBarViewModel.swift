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
import RxCoreLocation

extension MainTabBarViewModel {
    
    var locationRequestHidden: Driver<Bool> {
        
        return Driver.combineLatest(appState.changesOf { $0.currentUser },
                                    locationManager.rx.didChangeAuthorization.asDriver()
                                        .startWith((locationManager, CLLocationManager.authorizationStatus()))
            )
            { maybeUser, event in
                
                guard let u = maybeUser,
                    event.status != .notDetermined else {
                        
                        ///do not show dialog if
                        ///   no user logged in
                        ///or
                        ///   user hasn't made a decision yet
                        
                        return true
                }
                
                if let _ = u.community.lastKnownLocation {
                    ///do not show dialog if community exist
                    return true
                }
                
                return (event.status != .denied)
            }
        .distinctUntilChanged()
        
    }
 
    var unsupportedVersionTrigger: Driver<Bool> {
        return unsupportedVersionTriggerVar.asDriver()
            .filter { $0 }
    }
    
    var profileTabImage: Driver<UIImage> {
        return appState.changesOf { $0.currentUser?.bio.photos.avatar.thumbnailURL ?? "" }
            .flatMapLatest { ImageRetreiver.imageForURLWithoutProgress(url: $0) }
            .map { $0 ?? R.image.noPhoto()! }
            .map { RoundCornerImageProcessor(cornerRadius: 50, targetSize: .init(width: 100, height: 100))
                .process(item: ImageProcessItem.image($0), options: [])! }
            .map { $0.withRenderingMode(.alwaysOriginal) }
    }
    
}

struct MainTabBarViewModel : MVVM_ViewModel {

    private let locationManager = CLLocationManager()
    private let unsupportedVersionTriggerVar = BehaviorRelay(value: false)
    
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
        
        FetchConfig().rx.request
            .retry(2)
            .subscribe(onSuccess: { [weak t = unsupportedVersionTriggerVar] (config) in
                immutableNonPersistentState = .init(subscriptionProductID: config.IAPSubscriptionProductId)
                t?.accept(CocoaVersion.current < config.minSupportedIOSVersion.cocoaVersion)
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
