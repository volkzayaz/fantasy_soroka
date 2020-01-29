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
    
    var unreadRooms: Driver<Int> {
        return appState.changesOf { $0.rooms }
            .map { rooms -> Int in
                
                guard let r = rooms else {
                    return 0
                }
                    
                return r.filter { $0.unreadCount > 0 }
                    .count
            }

    }
    
    var unreadConnections: Driver<Int> {
        return appState.changesOf { $0.incommingConnections }
    }
    
    var appBadge: Driver<Int> {
        return Driver.combineLatest(unreadRooms, unreadConnections, resultSelector: +)
    }
    
}

struct MainTabBarViewModel : MVVM_ViewModel {

    private let locationManager = CLLocationManager()
    
    init(router: MainTabBarRouter) {
        self.router = router
        
        appState.changesOf { $0.inviteDeeplink }
            .notNil()
            .asObservable()
            .flatMap { [unowned i = indicator] x in
                RoomManager.assosiateSelfWith(roomRef: x.roomRef, password: x.password)
                    .trackView(viewIndicator: i)
            }
            .subscribe(onNext: { (room) in
                router.presentRoom(room: room, page: .chat)
            })
            .disposed(by: bag)
        
        appState.changesOf { $0.openRoom }
            .notNil()
            .asObservable()
            .flatMap { [unowned i = indicator] x in
                RoomManager.getRoom(id: x.roomRef.id)
                    .trackView(viewIndicator: i)
            }
            .subscribe(onNext: { (room) in
                router.presentRoom(room: room, page: .chat)
            })
            .disposed(by: bag)
        
        appState.changesOf { $0.openCard }
            .notNil()
            .asObservable()
            .flatMap { [unowned i = indicator] x in

                return Single.zip(Fantasy.Manager.card(by: x.cardId),
                                  RoomManager.room(with: x.senderId),
                                  Fantasy.Manager.fetchCollections()
                )
                        .trackView(viewIndicator: i)
                
            }
            .subscribe(onNext: { (card, maybeRoom, collections) in
                
                if let x = maybeRoom {
                    router.presentCardDetails(card: card, in: x)
                }
                else {
                    
                    let prefsEnabled = card.isFree || collections.contains { $0.isPurchased && $0.title == card.collectionName }
                    
                    router.presentCardDetails(card: card, preferencesEnabled: prefsEnabled)
                }
                
            })
            .disposed(by: bag)
        
        
        appState.changesOf { $0.openCollection }
            .notNil()
            .asObservable()
            .flatMap { [unowned i = indicator] x in
                Fantasy.Manager.collection(by: x.id)
                    .trackView(viewIndicator: i)
            }
            .subscribe(onNext: { (collection) in
                router.present(collection: collection)
            })
            .disposed(by: bag)
        
        ///Rooms stuff
        
        appState.changesOf { $0.rooms }
            .notNil()
            .distinctUntilChanged { $0.count == $1.count }
            .asObservable()
            .flatMapLatest { (rooms) in
                RoomManager.latestMessageIn(rooms: rooms)
            }
            .subscribe(onNext: { (message) in
                Dispatcher.dispatch(action: NewMessageSent(message: message))
            })
            .disposed(by: bag)
        
        appState.changesOf { $0.reloadRoomsTriggerBecauseOfComplexFreezeLogic }
            .filter { $0 }
            .asObservable()
            .flatMapFirst { _ -> Observable<[Room]> in
                return RoomManager.getAllRooms()
                    .asObservable()
                    .silentCatch(handler: router.owner)
            }
            .subscribe(onNext: { (rooms: [Room]) in
                Dispatcher.dispatch(action: SetRooms(rooms: rooms))
            })
            .disposed(by: bag)
        
        Dispatcher.dispatch(action: TriggerRoomsRefresh())
        
        /////progress indicator
        
        indicator.asDriver()
            .drive(onNext: { [weak h = router.owner] (loading) in
                h?.setLoadingStatus(loading)
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
