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

        ///indicator
        
    }

    let router: RoomsRouter
    let indicator: ViewIndicator = ViewIndicator()
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
