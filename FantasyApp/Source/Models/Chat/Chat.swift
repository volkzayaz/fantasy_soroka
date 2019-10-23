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

extension Room {

    class Message: Equatable, IdentifiableType, ParsePresentable {
        static func == (lhs: Room.Message, rhs: Room.Message) -> Bool {
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

struct RoomRef: Equatable {
    let id: String
}

struct Room: Codable, Equatable, IdentifiableType, Hashable {
    
    let id: String
    let ownerId: String
    
    var settings: Settings
    
    let status = Status.draft
    
    let freezeStatus: FreezeStatus
    var participants = [Participant]()

    // property are set during runtime
    var notificationSettings: RoomNotificationSettings?
    
    var identity: String {
        return id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
}

extension Room {
    
    enum FreezeStatus: String, Codable, Equatable {
        case frozen
        case unfrozen
        case unfrozenPaid
    }

    struct Settings: Codable, Equatable {
        var isClosedRoom = false
        var isHideCommonFantasies = false
        var isScreenShieldEnabled = false
        var sharedCollections: [String]
    }

    struct Participant: Codable, Equatable, IdentifiableType {
        var identity: String {
            return  userId ?? invitationLink ?? ""
        }
        
        var status = Status.accepted
        
        private let _id: String
        private let userId: String?
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

    enum `Type`: String, Codable, Equatable {
        case `private`
        case `public`
    }

    enum Status: String, Codable, Equatable {
        case draft
        case created
    }

}

