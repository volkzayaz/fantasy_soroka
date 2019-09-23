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

        var identity: String {
            return objectId!
        }

        enum CodingKeys: String, CodingKey {
            case senderDisplayName
            case senderId
            case recepientId = "recipientId"
            case text
            case objectId
            case roomId
            case isRead = "isReaded"
            case createdAt
        }

        var senderDisplayName: String?
        let senderId: String
        let recepientId: String
        var text: String?
        var objectId: String?
        let roomId: String
        var isRead: Bool = false
        let createdAt: Date
    }

    struct Room: Equatable, IdentifiableType, ParsePresentable {
        static var className: String {
            return "Room"
        }

        var identity: String {
            return objectId!
        }

        var objectId: String?
        var updatedAt: Date?
        var owner: UserSlice?
        var recipient: UserSlice?
    }
}

// MARK: - MessageKit
extension Chat.Message: MessageType {
    var sender: SenderType {
        return Sender(senderId: senderId, displayName: senderDisplayName ?? "")
    }

    var messageId: String {
        return objectId!
    }

    var sentDate: Date {
        return createdAt
    }

    var kind: MessageKind {
        let message = text ?? ""
        return message.containsOnlyEmojis ? .emoji(message) : .text(message)
    }
}
