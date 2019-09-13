//
//  Chat.swift
//  FantasyApp
//
//  Created by Admin on 10.09.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxDataSources
import Parse
import MessageKit

enum Chat {}
extension Chat {

    struct Message: Equatable, IdentifiableType, ParsePresentable {
        static var className: String {
            return "SinchMessage"
        }

        var pfObjectId: String {
            return objectId
        }

        var identity: String {
            return pfObjectId
        }

        var senderDisplayName: String?
        var senderId: String!
        var recepientId: String?
        var updatedAt: Date?
        var text: String?
        var objectId: String!
        var roomId: String?
        var isRead: Bool = false
    }

    struct Room: Equatable, IdentifiableType, ParsePresentable {
        static var className: String {
            return "Room"
        }

        var pfObjectId: String {
            return objectId
        }

        var identity: String {
            return pfObjectId
        }

        var objectId: String!
        var updatedAt: Date?
        var owner: UserSlice?
        var recipient: UserSlice?
    }
}

extension Chat.Message: MessageType {
    var sender: SenderType {
        return Sender(senderId: senderId, displayName: senderDisplayName ?? "")
    }

    var messageId: String {
        return objectId
    }

    var sentDate: Date {
        return updatedAt ?? Date()
    }

    var kind: MessageKind {
        let message = text ?? ""
        return message.containsOnlyEmojis ? .emoji(message) : .text(message)
    }
}
