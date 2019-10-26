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
    let roomRef: RoomRef
    let password: String
    let status: Room.Participant.Status

    typealias responseType = Room

    var method: Moya.Method {
        return .post
    }

    var path: String {
        return "users/me/rooms/\(roomRef.id)/invite/response"
    }

    var task: Task {
        return .requestParameters(parameters: ["status": status.rawValue,
                                               "inviteToken": password],
                                  encoding: JSONEncoding())
    }
}

