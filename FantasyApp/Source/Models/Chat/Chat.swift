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
    
    struct Message: Equatable, IdentifiableType, Codable, SocketData {
        static func == (lhs: Room.Message, rhs: Room.Message) -> Bool {
            return lhs.messageId == rhs.messageId && lhs.roomId == rhs.roomId
        }

        var identity: String {
            return messageId
        }

        enum CodingKeys: String, CodingKey {
            case messageId
            case text
            case senderId
            case roomId
            case createdAt = "timestamp"
        }

        var messageId: String
        let text: String
        let senderId: String
        let roomId: String
        let createdAt: Date

        init(text: String,
             from user: User,
             in room: Room) {
            
            messageId = UUID().uuidString + "fresh message"
            senderId = user.id
            self.text = text
            
            roomId = room.id
            
            createdAt = Date()
        }
        
        func socketRepresentation() -> SocketData {
            return ["text": text, "roomId": roomId]
        }
        
        var isOwn: Bool {
            return senderId == User.current?.id
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

    var lastMessage: Message? { return nil }
    
    var peer: Participant {
        return participants.first(where: { $0.userId != User.current?.id })!
    }
    
    var me: Participant {
        return participants.first(where: { $0.userId == User.current?.id })!
    }
    
    // property set during runtime
    var notificationSettings: NotificationSettings!
    
    var identity: String {
        return id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
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
        
        private let _id: String
        let userId: String?
        private let userName: String?
        private let avatarThumbnail: String?
        let invitationLink: String?
        
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

