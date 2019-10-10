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
    struct CellModel: IdentifiableType, Equatable {
        let companionName: String
        let updatedAt: String
        let lastMessage: String
        let identifier: String

        var identity: String {
            return identifier
        }
    }

    var dataSource: Driver<[AnimatableSectionModel<String, RoomsViewModel.CellModel>]> {
        return rooms.map { rooms in
            let models: [CellModel] = rooms?.filter { $0.status == .created }.map { room in
                return CellModel(companionName: room.roomName ?? "",
                                 updatedAt: (room.details?.updatedAt ?? Date()).toTimeAgoString(),
                                 lastMessage: room.details?.lastMessage ?? "",
                                 identifier: room.id)
            } ?? []
            return [AnimatableSectionModel(model: "", items: models)]
        }
    }
}

struct RoomsViewModel: MVVM_ViewModel {
    var rooms: Driver<[Chat.Room]?> {
        return appState.changesOf { $0.rooms }
    }

    init(router: RoomsRouter) {
        self.router = router

        indicator.asDriver().drive(onNext: { [weak h = router.owner] (loading) in
            h?.setLoadingStatus(loading)
        }).disposed(by: bag)
    }

    let router: RoomsRouter
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
}

extension RoomsViewModel {
    func roomTapped(_ model: RoomsViewModel.CellModel) {
        guard let room = appStateSlice.rooms
            .first(where: { $0.id == model.identifier }) else {
                return
        }

        router.roomTapped(room)
    }

    func fetchRooms() {
        ChatManager.getRooms()
            .trackView(viewIndicator: indicator)
            .silentCatch(handler: router.owner)
            .subscribe(onNext: { _ in })
            .disposed(by: bag)
    }

    func createRoom() {
        ChatManager.createDraftRoom()
            .trackView(viewIndicator: indicator)
            .silentCatch(handler: router.owner)
            .subscribe(onNext: { _ in })
            .disposed(by: bag)
    }
}
