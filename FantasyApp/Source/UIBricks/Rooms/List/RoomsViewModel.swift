//
//  RoomsViewModel.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 10.09.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

extension RoomsViewModel {
    
    var dataSource: Driver<[AnimatableSectionModel<String, Room>]> {
        return appState.changesOf { $0.rooms }
            .notNil()
            .map { cells in
                
                let freezed = Dictionary(grouping: cells, by: { $0.freezeStatus == .frozen })
                
                var results: [AnimatableSectionModel<String, Room>] = []
                
                if let x = freezed[false] {
                    results.append(AnimatableSectionModel(model: "Non Freezed rooms",
                                                          items: x))
                }
                
                if let x = freezed[true] {
                    results.append(AnimatableSectionModel(model: "Freezed rooms",
                                                          items: x))
                }
                
                return results
            }
    }
    
}

struct RoomsViewModel: MVVM_ViewModel {
    
    init(router: RoomsRouter) {
        self.router = router

        ///Rooms refresh
        
        appState.changesOf { $0.reloadRoomsTriggerBecauseOfComplexFreezeLogic }
            .filter { $0 }
            .asObservable()
            .flatMapFirst { [unowned i = indicator] _ -> Observable<[Room]> in
                return RoomManager.getAllRooms()
                    .asObservable()
                    .trackView(viewIndicator: i)
                    .silentCatch(handler: router.owner)
            }
            .subscribe(onNext: { (rooms: [Room]) in
                Dispatcher.dispatch(action: SetRooms(rooms: rooms))
            })
            .disposed(by: bag)
        
        Dispatcher.dispatch(action: TriggerRoomsRefresh())
        
        ///Global stuff, binding webSocket to appState
        
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
        
        ///indicator
        
        indicator.asDriver().drive(onNext: { [weak h = router.owner] (loading) in
            h?.setLoadingStatus(loading)
        }).disposed(by: bag)
    }

    let router: RoomsRouter
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
}

extension RoomsViewModel {
    
    func roomTapped(room: Room) {
        
        guard room.freezeStatus != .frozen else {
            
            return router.owner.showDialog(title: "Club Membership",
                                           text: R.string.localizable.roomFrozenRoomUnreachable(),
                                           style: .alert, negativeText: "Upgrade",
                                           negativeCallback: router.showSubscription,
                                           positiveText: "No, thanks")
        }
            
        router.roomTapped(room)
    }

    func createRoom() {
        
        RoomManager.createDraftRoom()
            .trackView(viewIndicator: indicator)
            .silentCatch(handler: router.owner)
            .subscribe(onNext: { room in
                self.router.showRoomSettings(room)                
            })
            .disposed(by: bag)

    }
    
    func refreshRooms() {
        Dispatcher.dispatch(action: TriggerRoomsRefresh())
    }
    
}
