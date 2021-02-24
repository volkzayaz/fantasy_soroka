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

class RoomsViewModel: MVVM_ViewModel {
    
    init(router: RoomsRouter) {
        self.router = router

        ///indicator
        webSocket.didReceiveRoomChange
            .map { _ in TriggerRoomsRefresh() }
            .subscribe(onNext: Dispatcher.dispatch)
            .disposed(by: bag)
    }

    let router: RoomsRouter
    let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
}

extension RoomsViewModel {
    
    func roomTapped(room: Room) {
        
        guard room.freezeStatus != .frozen else {
            
            return router.owner.showDialog(
                title: R.string.localizable.roomUpgradeSuggestionTitle(),
                text: R.string.localizable.roomFrozenRoomUnreachable(),
                style: .alert,
                negativeText: R.string.localizable.roomUpgradeSuggestionNegativeText2(),
                negativeCallback: router.showSubscription,
                positiveText: R.string.localizable.roomUpgradeSuggestionPositiveText())
        }
            
        router.open(room, page: .chat)
    }
    
    func createRoom() {
        
        Analytics.report(Analytics.Event.DraftRoomCreated())
        
        RoomManager.createDraftRoom()
            .trackView(viewIndicator: indicator)
            .silentCatch(handler: router.owner)
            .subscribe(onNext: { [unowned self] room in
                self.router.open(room, page: .play)
            })
            .disposed(by: bag)
        
    }
    
    func refreshRooms() {
        Dispatcher.dispatch(action: TriggerRoomsRefresh())
    }
    
}
