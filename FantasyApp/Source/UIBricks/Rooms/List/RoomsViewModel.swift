//
//  RoomsViewModel.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 10.09.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

extension RoomsViewModel {
    
    var dataSource: Driver<[AnimatableSectionModel<String, RoomCell>]> {
        return appState.changesOf { $0.rooms }
            .flatMapLatest { rooms -> Driver<[RoomCell]> in
                
                return RoomManager.latestMessageIn(rooms: rooms)
                    .asDriver(onErrorJustReturn: [:])
                    .map { messages in
                        messages.map {
                        RoomCell(room: $0.key, lastMessage: $0.value) }
                    }
                
            }
            .map { cells in
                
                let freezed = Dictionary(grouping: cells, by: { $0.room.freezeStatus == .frozen })
                
                return [
                    AnimatableSectionModel(model: "Non Freezed rooms", items: freezed[false]!),
                    AnimatableSectionModel(model: "Freezed rooms", items: freezed[true]!)
                ]
            }
    }
    
    struct RoomCell: IdentifiableType, Equatable {
        let room: Room
        let lastMessage: Room.Message?
        
        var identity: String {
            return room.id
        }
    }
}

struct RoomsViewModel: MVVM_ViewModel {
    
    init(router: RoomsRouter) {
        self.router = router

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
        
        indicator.asDriver().drive(onNext: { [weak h = router.owner] (loading) in
            h?.setLoadingStatus(loading)
        }).disposed(by: bag)
    }

    let router: RoomsRouter
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
}

extension RoomsViewModel {
    
    func roomTapped(roomCell: RoomCell) {
        
        guard roomCell.room.freezeStatus != .frozen else {
            return router.messagePresentable.presentMessage("This room is currently frozen, you can't use it at the moment. Upgrade to premium")
        }
        
        router.roomTapped(roomCell.room)
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
