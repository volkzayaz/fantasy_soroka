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

enum ChatManager {}
extension ChatManager {
    static func sendMessage(_ message: Chat.Message) -> Single<Void> {
        return message.rxCreate().map { _ in }
    }

    static func getMessagesInRoom(_ roomId: String, offset: Int = 0, limit: Int = 30) -> Single<[Chat.Message]> {
        let query = PFQuery(className: Chat.Room.className)
        query.whereKey("roomId", equalTo: roomId)
        query.addAscendingOrder("createdAt")
        query.skip = offset
        query.limit = limit

        return query.rx.fetchAll()
    }

    static func getRooms() -> Single<[Chat.Room]> {
        guard let user = PFUser.current() else {
            return .error(FantasyError.unauthorized)
        }

        let predicate = NSPredicate(format: "owner == %@ OR recipient == %@", user, user)
        let query = PFQuery(className: Chat.Room.className, predicate: predicate)
        query.addDescendingOrder("updatedAt")

        return query.rx.fetchAll()
    }

    static func createRoom(_ room: Chat.Room) -> Single<Void> {
        return room.rxCreate().map { _ in }
    }
}

