//
//  File.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 9/20/19.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

enum ConnectionRequestType: String, Codable {
    case like
    case message
    case sticker
}

///between ME and other User
enum Connection {
    case absent
    case incomming(request: ConnectionRequestType)
    case outgoing(request: ConnectionRequestType)
    case iRejected    ///I initiated it, but other user doesn't want it
    case iWasRejected ///Other user initiated it, but I don't want it
    case mutual
}
