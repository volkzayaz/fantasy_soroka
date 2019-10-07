//
//  ChatManager.swift
//  FantasyApp
//
//  Created by Admin on 10.09.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Parse
import ParseLiveQuery

enum ChatManager {
    enum ChatEvent {
        case messageAdded(Chat.Message)
        case messageRemoved(Chat.Message)
        case messageUpdated(Chat.Message)
    }
    private static var query: PFQuery<PFObject> = PFQuery(className: Chat.Message.className)
}
extension ChatManager {
    static func sendMessage(_ message: Chat.Message) -> Single<Void> {
        return message.rxCreate().map { _ in }
    }

    static func getMessagesInRoom(_ roomId: String, offset: Int = 0, limit: Int = 30) -> Single<[Chat.Message]> {
        let query = PFQuery(className: Chat.Message.className)
        query.whereKey("roomId", equalTo: roomId)
        query.addAscendingOrder("createdAt")
        query.skip = offset
        query.limit = limit

        return query.rx.fetchAll()
    }

    static func getRoomsDetails() -> Single<[Chat.RoomDetails]> {
        guard let user = PFUser.current() else {
            return .error(FantasyError.unauthorized)
        }

        let predicate = NSPredicate(format: "owner == %@ OR recipient == %@", user, user)
        let query = PFQuery(className: Chat.RoomDetails.className, predicate: predicate)
        query.addDescendingOrder("updatedAt")

        return query.rx.fetchAll()
    }

    static func getRooms() -> Single<[Chat.Room]> {
        return RoomsResource().rx.request.map { $0 }
    }

    static func createRoomDetails(_ roomDetails: Chat.RoomDetails) -> Single<Void> {
        return roomDetails.rxCreate().map { _ in }
    }

    static func connect(roomId: String) -> Observable<ChatEvent> {
        return Observable.create { (subscriber) -> Disposable in
            query.addDescendingOrder("updatedAt")
            query.whereKey("roomId", equalTo: roomId)

            let subscription: Subscription<PFObject> = Client.shared.subscribe(query)
            subscription.handleEvent { object, e in
                var event: ChatEvent
                switch e {
                case .entered(let messageObject), .created(let messageObject):
                    let message: Chat.Message = [messageObject].toCodable().first!
                    event = .messageAdded(message)
                case .deleted(let messageObject), .left(let messageObject):
                    let message: Chat.Message = [messageObject].toCodable().first!
                    event = .messageRemoved(message)
                case .updated(let messageObject):
                    let message: Chat.Message = [messageObject].toCodable().first!
                    event = .messageUpdated(message)
                }
                subscriber.onNext(event)
            }

            return Disposables.create()
        }
    }

    static func disconnect(roomId: String) {
        query.addDescendingOrder("updatedAt")
        query.whereKey("roomId", equalTo: roomId)

        Client.shared.unsubscribe(query)
    }
}

