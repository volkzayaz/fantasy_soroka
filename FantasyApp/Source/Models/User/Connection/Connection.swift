//
//  File.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/20/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import RxDataSources

enum ConnectionRequestType: String, Codable {
    case like
    case message
    case sticker
    case inviteLink = "link"
}

///between ME and other User
enum Connection {

    case sameUser ///I am not in connection with myself
    case absent
    case incomming(request: Set<ConnectionRequestType>, draftRoom: RoomRef)
    case outgoing(request: Set<ConnectionRequestType>, draftRoom: RoomRef)
    case iRejected    ///Other user initiated it, but I don't want it
    case iWasRejected ///I initiated it, but other user doesn't want it
    case mutual(room: RoomRef)
    
}

struct ConnectedUser: Equatable, IdentifiableType {
    let user: User
    let room: RoomRef
    let connectTypes: Set<ConnectionRequestType>
    
    var identity: String {
        return user.id
    }
}

extension ConnectionRequestType {
    
    var requestImage: UIImage {
        switch self {
        case .like:         return R.image.requestLike()!
        case .message:      return R.image.requestMessage()!
        case .sticker:      return R.image.requestSticker()!
        case .inviteLink:   return R.image.requestLink()!
        }
    }
    
}
