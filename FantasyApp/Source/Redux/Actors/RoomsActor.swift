//
//  RoomsActor.swift
//  FantasyApp
//
//  Created by Admin on 10.09.2019.
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
        guard let user = PFUser.current() else {
            return
        }

        let predicate = NSPredicate(format: "owner == %@ OR recipient == %@", user, user)
        query = PFQuery(className: "Room", predicate: predicate)
        query!.addDescendingOrder("updatedAt")

        let subscription: Subscription<PFObject> = Client.shared.subscribe(query!)
        subscription.handleEvent { object, event in
            var action: Action
            switch event {
            case .entered(let roomObject), .created(let roomObject):
                action = AddRooms(rooms: [roomObject].toCodable())
            case .deleted(let roomObject), .left(let roomObject):
                action = RemoveRoom(room: [roomObject].toCodable().first!)
            case .updated(let roomObject):
                action = UpdateRoom(room: [roomObject].toCodable().first!)
            }
            Dispatcher.dispatch(action: action)
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
