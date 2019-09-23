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

///between 2 users
enum Connection {
    case absent
    case incomming(request: ConnectionRequestType)
    case outgoing(request: ConnectionRequestType)
    case rejected ///poor fela, there're plenty of fish in the sea ;)
    case mutual
}
