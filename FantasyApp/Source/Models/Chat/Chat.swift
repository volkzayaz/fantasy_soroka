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

        var objectId: String?
        
        let senderDisplayName: String
        let text: String
        
        let senderId: String
        let roomId: String
        
        var isRead: Bool = false
        
        let createdAt: Date

        init(text: String,
             from user: User,
             in room: Room) {
             
            self.senderDisplayName = user.bio.name
            self.senderId = user.id
            self.text = text
            
            self.roomId = room.id
            
            self.createdAt = Date()
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
        return text.containsOnlyEmojis ? Chat.CellType.emoji.rawValue :
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
        var backendId: String!
        
        
        
        ///the only two usefull entities here
        var updatedAt: Date?
        var lastMessage: String?
    }

    struct RoomRef: Equatable {
        let id: String
    }
    
    struct Room: Codable, Equatable, IdentifiableType {
        
        let id: String
        let ownerId: String
        
        var settings: RoomSettings
        
        let status = RoomStatus.draft
        
        var roomName: String { return "hello" }
        
        var freezeStatus: RoomFreezeStatus?
        var participants = [RoomParticipant]()

        // property are set during runtime
        var details: RoomDetails?
        var notificationSettings: RoomNotificationSettings?
        
        var identity: String {
            return id
        }
        
    }

    enum RoomFreezeStatus: String, Codable, Equatable {
        case frozen
        case unfrozen
        case unfrozenPaid
    }

    struct RoomSettings: Codable, Equatable {
        var isClosedRoom = false
        var isHideCommonFantasies = false
        var isScreenShieldEnabled = false
        var sharedCollections: [String]
    }

    struct RoomParticipant: Codable, Equatable, IdentifiableType {
        var identity: String {
            return _id!
        }

        var _id: String!
        var userId: String?
        var status: RoomParticipantStatus = .accepted
        var invitationLink: String?
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
