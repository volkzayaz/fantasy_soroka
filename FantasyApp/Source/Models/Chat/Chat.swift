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
import ChattoAdditions
import Chatto

enum Chat {}
extension Chat {

    class Message: Equatable, IdentifiableType, ParsePresentable {
        static func == (lhs: Chat.Message, rhs: Chat.Message) -> Bool {
            return lhs.objectId == rhs.objectId && lhs.roomId == rhs.roomId
        }

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

        init(senderDisplayName: String?,
             senderId: String,
             recepientId: String,
             text: String?,
             objectId: String?,
             roomId: String,
             isRead: Bool = false,
             createdAt: Date) {
            self.senderDisplayName = senderDisplayName
            self.senderId = senderId
            self.recepientId = recepientId
            self.text = text
            self.objectId = objectId
            self.roomId = roomId
            self.isRead = isRead
            self.createdAt = createdAt
        }
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
        var backendId: String?
    }
}

// MARK: - Chatto
extension Chat.Message: MessageModelProtocol {
    var isIncoming: Bool {
        return senderId != User.current?.id
    }

    var date: Date {
        return createdAt
    }

    var status: MessageStatus {
        return .success
    }

    enum Kind: String {
        case text = "text-chat-message"
        case emoji = "emoji-chat-message"
    }

    var type: ChatItemType {
        return (text ?? "").containsOnlyEmojis ? Chat.Message.Kind.emoji.rawValue :
            Chat.Message.Kind.text.rawValue
    }

    var uid: String {
        return objectId ?? ""
    }
}
