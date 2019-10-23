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
    
    var dataSource: Driver<[AnimatableSectionModel<String, Chat.Room>]> {
        return appState.changesOf { $0.rooms }
            .map { [AnimatableSectionModel(model: "", items: $0)] }
        
    }
}

struct RoomsViewModel: MVVM_ViewModel {
    
    init(router: RoomsRouter) {
        self.router = router
//
//        source = AppState.rooms
//
//        wipeReloadTriger = first + pull to refresh + marker on complex logic changed
//
        
        ////dependency on allRooms with subscription to newMessage event, that updates UI
        ///1. kill parse RoomDetails
        ///2. Kill RoomActor's subscription
        ///3. Create subscription on multiple rooms with propagating event (Message, Room)
        
        
        ChatManager.getAllRooms()
            .trackView(viewIndicator: indicator)
            .silentCatch(handler: router.owner)
            .subscribe(onNext: { _ in })
            .disposed(by: bag)
        
        indicator.asDriver().drive(onNext: { [weak h = router.owner] (loading) in
            h?.setLoadingStatus(loading)
        }).disposed(by: bag)
    }

    let router: RoomsRouter
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
}

extension RoomsViewModel {
    
    func roomTapped(_ room: Chat.Room) {
        router.roomTapped(room)
    }

    func createRoom() {
        
        ChatManager.createDraftRoom()
            .trackView(viewIndicator: indicator)
            .silentCatch(handler: router.owner)
            .subscribe(onNext: { room in
                self.router.showRoomSettings(room)
            })
            .disposed(by: bag)
        
    }
}
