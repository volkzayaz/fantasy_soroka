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
    static func sendMessage(_ message: Chat.Message) -> Maybe<Void> {
        return message.rxCreate()
    }

    static func getMessagesInRoom(_ roomId: String, offset: Int = 0) -> Maybe<[Chat.Message]> {
        let query = PFQuery(className: "SinchMessage")
        query.whereKey("roomId", equalTo: roomId)
        query.addAscendingOrder("createdAt")
        query.skip = offset
        query.limit = 30

        return query.rx.fetchAll()
    }

    static func getRooms() -> Maybe<[Chat.Room]> {
        guard let user = PFUser.current() else {
            return .error(FantasyError.unauthorized)
        }

        let predicate = NSPredicate(format: "owner == %@ OR recipient == %@", user, user)
        let query = PFQuery(className: "Room", predicate: predicate)
        query.addDescendingOrder("updatedAt")

        return query.rx.fetchAll()
    }

    static func createRoom(_ room: Chat.Room) -> Maybe<Void> {
       return room.rxCreate()
    }
}

