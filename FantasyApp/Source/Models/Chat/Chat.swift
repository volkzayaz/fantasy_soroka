//
//  Chat.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 10.09.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxDataSources
import SocketIO

extension Room {
    
    struct Message: Equatable, IdentifiableType, Codable {
        static func == (lhs: Room.Message, rhs: Room.Message) -> Bool {
            return lhs.messageId == rhs.messageId && lhs.nonNullHackyText == rhs.nonNullHackyText
        }

        var identity: String {
            return messageId
        }

        enum CodingKeys: String, CodingKey {
            case messageId
            case text
            case senderId
            case createdAt = "timestamp"
            case type
            case readUserIds
        }

        var messageId: String
        let text: String?
        let senderId: String
        let createdAt: Date
        let type: MessageType
        var readUserIds: Set<String>?
        
        var isRead: Bool { readUserIds?.contains { $0 == User.current?.id } ?? false }
        
        mutating func markRead() {
            readUserIds?.insert(User.current!.id)
        }
        
        var nonNullHackyText: String {
            return text ?? ""
        }
        
        var isOwn: Bool {
            return senderId == User.current?.id
        }
        
        enum MessageType: String, Codable {
            case message
            case message_deleted
            case invited
            case like
            case created
            case deleted, sp_enabled, sp_disabled, settings_changed, frozen, unfrozen, unfrozenPaid
        }
        
        func typeDescription(peer: String) -> String {
            
            switch type {
                
            case .created:
                return R.string.localizable.chatMessageTypeCreated()
                
            case .like:
                return isOwn ? R.string.localizable.chatMessageTypeLikeOwn(peer) : R.string.localizable.chatMessageTypeLike(peer)
                
            case .invited:
                return isOwn ? R.string.localizable.chatMessageTypeInvitedOwn(peer) : R.string.localizable.chatMessageTypeInvited(peer)
                
            case .message:
                return text ?? ""
                
            case .sp_enabled, .sp_disabled: fallthrough
            case .settings_changed:
                return R.string.localizable.chatMessageTypeSettingsChanged()
                
            case .frozen:
                return isOwn ? R.string.localizable.chatMessageTypeFrozenOwn() : R.string.localizable.chatMessageTypeFrozen(peer)
                
            case .unfrozen:
                return R.string.localizable.chatMessageTypeUnfrozen()
                
            case .unfrozenPaid:
                let name = isOwn ? R.string.localizable.chatMessageTypeYou() : "\(peer)"
                return R.string.localizable.chatMessageTypeUnfrozenPaid(name)
                
            case .message_deleted:
                return R.string.localizable.chatMessageTypeMessageDeleted()
                
            case .deleted:
                return R.string.localizable.chatMessageTypeDeleted()
                
            }
            
        }
    }
    
    struct MessageInRoom: Codable, SocketData {
        var raw: Message
        let roomId: String
        
        enum CodingKeys: String, CodingKey {
            case roomId
        }
        
        init(from decoder: Decoder) throws {
            raw = try .init(from: decoder)
            roomId = try (try decoder.container(keyedBy: CodingKeys.self))
                .decode(String.self, forKey: .roomId)
        }
        
        init(text: String,
             from user: User,
             in room: Room) {
            
            raw = Message(messageId: UUID().uuidString + "fresh message",
                          text: text,
                          senderId: user.id,
                          createdAt: Date(),
                          type: .message,
                          readUserIds: [user.id])
            
            roomId = room.id
        }
        
        init(raw: Message, roomId: String) {
            self.raw = raw
            self.roomId = roomId
        }
        
        func socketRepresentation() -> SocketData {
            return ["text": raw.nonNullHackyText, "roomId": roomId]
        }
        
    }
    
    struct ReadStatus: Codable, SocketData {
        
        let roomId: String
        let userId: String
        let messageId: String
        
        func socketRepresentation() -> SocketData {
            return ["messageId": messageId, "roomId": roomId, "userId": userId]
        }
        
    }
    
}

struct RoomRef: Equatable {
    let id: String
}

struct Room: Codable, Equatable, IdentifiableType, Hashable {
    
    let id: String
    let ownerId: String
    
    var settings: Settings
    
    let freezeStatus: FreezeStatus?
    var participants: [Participant]

    var lastMessage: Message?
    
    var unreadCount: Int! = 0
    
    var peer: Participant {
        if let peer = participants.first(where: { $0.userId != User.current?.id }) {
            return peer
        }
        
        return Participant(userName: "", userId: "", avatar: "")
    }
    
    var me: Participant {
        return participants.first(where: { $0.userId == User.current?.id })!
    }
    
    var identity: String {
        return id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var isEmptyRoom: Bool {
        return participants.count == 1
    }
    
    var isDraftRoom: Bool {
        return participants.reduce(into: false) { result, participant in
            result = result || participant.status == .invited
        }
    }
    
    var isWaitingForMyResponse: Bool {
        return participants.contains(where: { $0.status == .invited && $0.userId == User.current?.id })
    }
    
}

extension Room {
    
    enum FreezeStatus: String, Codable, Equatable {
        case frozen
        case unfrozen
        case unfrozenPaid
    }

    struct Settings: Codable, Equatable {
        var isClosedRoom: Bool
        var isHideCommonFantasies: Bool
        var isScreenShieldEnabled: Bool
        var sharedCollections: [String]
        
        var notifications: Notifications

        
        struct Notifications: Codable, Equatable {
            var newMessage: Bool
            var newFantasyMatch: Bool
        }
        
    }
    
    struct Participant: Codable, Equatable, IdentifiableType {
        var identity: String {
            return  userId ?? invitationLink ?? ""
        }
        
        var status = Status.accepted
    
        let userId: String?
        private let userName: String?
        private let avatarThumbnail: String?
        let invitationLink: String?
        
        init(userName: String, userId: String, avatar: String) {
            self.userName = userName
            self.userId = userId
            self.avatarThumbnail = avatar
            self.invitationLink = ""
        }
        
        var userSlice: UserSlice {
            
            guard let userId = userId, let userName = userName, let avatarThumbnail = avatarThumbnail else {
                fatalErrorInDebug("This Participant is not a valid user. Details \(self)")
                return .init(id: "-1", name: "", avatarURL: "")
            }

            return .init(id: userId, name: userName, avatarURL: avatarThumbnail)
            
        }
        
        struct UserSlice {
            let id: String
            let name: String
            let avatarURL: String
        }
        
        
        enum Status: String, Codable, Equatable {
            case invited
            case accepted
            case rejected
        }
    }

}

