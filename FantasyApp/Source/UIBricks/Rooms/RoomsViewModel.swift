//
//  RoomsViewModel.swift
//  FantasyApp
//
//  Created by Admin on 10.09.2019.
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
            let models: [CellModel] = rooms?.map { room in
                var companion: UserSlice?
                if let ownerId = room.owner?.objectId,
                    ownerId == PFUser.current()?.objectId {
                    companion = room.recipient
                } else {
                    companion = room.owner
                }

                return CellModel(companionName: companion?.name ?? "",
                                 updatedAt: "7 min ago", // TODO: display real date
                                 lastMessage: room.messages?.first?.text ?? "",
                                 identifier: room.objectId)
            } ?? []
            return [AnimatableSectionModel(model: "", items: models)]
        }
    }
}

struct RoomsViewModel : MVVM_ViewModel {
    var rooms: Driver<[Chat.Room]?> {
        return appState.changesOf { $0.currentUser?.connections.rooms }
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
    func roomTapped(_ room: Chat.Room) {
        router.roomTapped(room)
    }

//    Test code to create room with Andriy
//    func createRoomWithAdmin() {
//        let query = PFUser.query()!.whereKey("fbId", equalTo: "113922985842130" as NSString)
//        query.findObjectsInBackground { (objects, error) in
//            if error == nil,
//                let admin = objects?.first as? PFUser,
//                let currentUser = PFUser.current() {
//                let room = PFObject(className: "Room")
//                let recipientRelation = room.relation(forKey: "recipient")
//                let ownerRelation = room.relation(forKey: "owner")
//                recipientRelation.add(currentUser)
//                ownerRelation.add(admin)
//                room.saveInBackground(block: { (didSave, maybeError) in })
//            }
//        }
//    }

    func fetchRooms() {
        ChatManager.getRooms()
            .trackView(viewIndicator: indicator)
            .silentCatch(handler: router.owner)
            .subscribe(onNext: { r in
                Dispatcher.dispatch(action: SetRooms(rooms: r))
            })
            .disposed(by: bag)
    }
}
