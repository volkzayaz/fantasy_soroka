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

    static func sendMessage(_ message: Chat.Message) -> Maybe<Void> {
        return message.rxCreate()
    }

    static func getMessagesInRoom(_ roomId: String, offset: Int = 0, limit: Int = 30) -> Maybe<[Chat.Message]> {
        let query = PFQuery(className: Chat.Room.className)
        query.whereKey("roomId", equalTo: roomId)
        query.addAscendingOrder("createdAt")
        query.skip = offset
        query.limit = limit

        return query.rx.fetchAll()
    }

    static func getRooms() -> Maybe<[Chat.Room]> {
        guard let user = PFUser.current() else {
            return .error(FantasyError.unauthorized)
        }

        let predicate = NSPredicate(format: "owner == %@ OR recipient == %@", user, user)
        let query = PFQuery(className: Chat.Room.className, predicate: predicate)
        query.addDescendingOrder("updatedAt")

        return query.rx.fetchAll()
    }

    static func createRoom(_ room: Chat.Room) -> Maybe<Void> {
       return room.rxCreate()
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

