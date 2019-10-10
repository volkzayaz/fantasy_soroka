//
//  RoomsActor.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 10.09.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift
import ParseLiveQuery

class RoomsActor {
    var query: PFQuery<PFObject>?

    init() {
        appState.changesOf { $0.currentUser }.drive(onNext: { [weak self] user in
            if user != nil {
                self?.addSubscription()
            } else {
                self?.removeSubscription()
            }
        }).disposed(by: bag)
    }

    private func addSubscription() {
        guard let userId = AuthenticationManager.currentUser()?.id else {
            return
        }

        let predicate = NSPredicate(format: "ownerId == %@ OR recipientId == %@", userId, userId)
        query = PFQuery(className: Chat.RoomDetails.className, predicate: predicate)
        query!.addDescendingOrder("updatedAt")

        let subscription: Subscription<PFObject> = Client.shared.subscribe(query!)
        subscription.handleEvent { object, event in
            switch event {
            case .entered(let roomObject),
                 .created(let roomObject),
                 .updated(let roomObject):
                let roomDetails: Chat.RoomDetails = [roomObject].toCodable().first!
                guard var room = appStateSlice.rooms
                    .first(where: { $0.id == roomDetails.backendId }) else {
                        return
                }
                room.details = roomDetails

               Dispatcher.dispatch(action: UpdateRoom(room: room))
            case .deleted(let roomObject),
                 .left(let roomObject):
                let roomDetails: Chat.RoomDetails = [roomObject].toCodable().first!
                guard var room = appStateSlice.rooms
                     .first(where: { $0.id == roomDetails.backendId }) else {
                         return
                 }
                 room.details = nil

                Dispatcher.dispatch(action: UpdateRoom(room: room))
            }
        }
    }

    private func removeSubscription() {
        guard let query = query else {
            return
        }
        Client.shared.unsubscribe(query)
    }

    private let bag = DisposeBag()
}
