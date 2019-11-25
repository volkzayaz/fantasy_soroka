//
//  MesagesIn.swift
//  FantasyApp
//
//  Created by Vlad Soroka on 25.11.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import Moya

struct MesagesIn: AuthorizedAPIResource {
    
    struct Response: Codable {
        let messages: [Room.Message]
        let totalCount: Int
    }
    
    typealias responseType = Response

    var method: Moya.Method {
        return .get
    }

    var path: String {
        return "users/me/rooms/\(room.id)/messages"
    }

    var task: Task {
        return .requestPlain
    }
    
    let room: RoomIdentifier
}
