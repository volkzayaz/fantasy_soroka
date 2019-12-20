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
 
    var profileTabImage: Driver<(UIImage, UIImage)> {
        return appState.changesOf { $0.currentUser?.bio.photos.avatar.thumbnailURL ?? "" }
            .asObservable()
            .flatMapLatest { ImageRetreiver.imageForURLWithoutProgress(url: $0) }
            .map { $0 ?? R.image.noPhoto()! }
            .observeOn(SerialDispatchQueueScheduler(qos: .background))
            .map { ($0.resize(for: 36), $0.addPinkCircle(for: 36)) }
            .asDriver(onErrorJustReturn: nil)
            .notNil()
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
        
        /////progress indicator
        
//        indicator.asDriver()
//            .drive(onNext: { [weak h = router.owner] (loading) in
//                h?.setLoadingStatus(loading)
//            })
//            .disposed(by: bag)
        
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
