//
//  Chat.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 10.09.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxDataSources
import Parse
import ChattoAdditions
import Chatto

// MARK: - Messages
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
            case text
            case objectId
            case roomId
            case isRead = "isReaded"
            case createdAt
        }

        var senderDisplayName: String?
        let senderId: String
        var text: String?
        var objectId: String?
        let roomId: String
        var isRead: Bool = false
        let createdAt: Date

        init(senderDisplayName: String?,
             senderId: String,
             text: String?,
             objectId: String?,
             roomId: String,
             isRead: Bool = false,
             createdAt: Date) {
            self.senderDisplayName = senderDisplayName
            self.senderId = senderId
            self.text = text
            self.objectId = objectId
            self.roomId = roomId
            self.isRead = isRead
            self.createdAt = createdAt
        }
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

    var type: ChatItemType {
        return (text ?? "").containsOnlyEmojis ? Chat.CellType.emoji.rawValue :
            Chat.CellType.text.rawValue
    }

    var uid: String {
        return objectId ?? ""
    }
}

// MARK: - Cells
extension Chat {
    enum CellType: String {
        case text = "text-chat-message"
        case emoji = "emoji-chat-message"
        case timeSeparator = "time-separator"
    }
}

// MARK: - Rooms
extension Chat {
    struct RoomDetails: Equatable, IdentifiableType, ParsePresentable {
        static var className: String {
            return "Room"
        }

        var identity: String {
            return objectId!
        }

        var objectId: String?
        var ownerId: String!
        var recipientId: String?
        var updatedAt: Date?
        var lastMessage: String?
        var backendId: String!
    }

    struct Room: Codable, Equatable {
        var id: String!
        var ownerId: String!
        var settings: RoomSettings?
        var type = RoomType.public
        var status = RoomStatus.created
        var roomName: String?
        //var isFrozen = false
        var participants = [RoomParticipant]()
        var createdAt: String?
        var updatedAt: String?

        // property is set during runtime
        var details: RoomDetails?
        
        init(id: String) {
            self.id = id
        }
    }

    struct RoomSettings: Codable, Equatable {
        var isClosedRoom = false
        var isHideCommonFantasies = false
        var isScreenShieldEnabled = false
        var sharedCollections: [String]?
    }

    struct RoomParticipant: Codable, Equatable, IdentifiableType {
        var identity: String {
            return userId!
        }

        var userId: String!
        var status: RoomParticipantStatus = .accepted
    }

    enum RoomType: String, Codable, Equatable {
        case `private`
        case `public`
    }

    enum RoomStatus: String, Codable, Equatable {
        case draft
        case created
    }

    enum RoomParticipantStatus: String, Codable, Equatable {
        case invited
        case accepted
        case rejected
    }
}
