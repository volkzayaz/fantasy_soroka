//
//  RoomStatusResource.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 09.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import Moya

struct RoomStatusResource: AuthorizedAPIResource {
    private let roomId: String
    private let status: Room.Participant.Status

    init(roomId: String, status: Room.Participant.Status) {
        self.roomId = roomId
        self.status = status
    }

    typealias responseType = Room

    var method: Moya.Method {
        return .post
    }

    var path: String {
        return "users/me/rooms/\(roomId)/invite/response"
    }

    var task: Task {
        return .requestParameters(parameters: ["status": status.rawValue],
                                  encoding: JSONEncoding())
    }
}

