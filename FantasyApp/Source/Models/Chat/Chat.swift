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

// MARK: - Date Formatting
extension Date {
    private static let hoursAndMinutesDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.dateFormat = "HH:MM"
        return dateFormatter
    }()

    func toMessageTimestampString() -> String {
        return Date.hoursAndMinutesDateFormatter.string(from: self)
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
        var updatedAt: Date?
        var lastMessage: String?
        var owner: UserSlice?
        var recipient: UserSlice?
        var backendId: String?
    }

    struct Room: Codable {
        var id: String!
        var ownerId: String!
        var settings: RoomSettings?
        var type = RoomType.public
        var status = RoomStatus.created
        var name = ""
        var isFrozen = false
        var participants = [RoomParticipant]()
        var createdAt: String?
        var updatedAt: String?
    }

    struct RoomSettings: Codable {
        var isClosedRoom = false
        var isHideCommonFantasies = false
        var isScreenShieldEnabled = false
        var sharedCollections = [String]()
    }

    struct RoomParticipant: Codable {
        var id: String!
        var status: RoomParticipantStatus = .accepted
    }

    enum RoomType: String, Codable {
        case `private`
        case `public`
    }

    enum RoomStatus: String, Codable {
        case draft
        case created
    }

    enum RoomParticipantStatus: String, Codable {
        case invited
        case accepted
        case rejected
    }
}
