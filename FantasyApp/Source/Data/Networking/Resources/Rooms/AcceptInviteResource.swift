//
//  AcceptInviteResource.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 09.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import Moya

struct AcceptInviteResource: AuthorizedAPIResource {
    private let roomId: String

    init(roomId: String) {
        self.roomId = roomId
    }

    typealias responseType = Chat.Room

    var method: Moya.Method {
        return .post
    }

    var path: String {
        return "users/me/rooms/\(roomId)/invite"
    }

    var task: Task {
        return .requestParameters(parameters: ["status": Chat.RoomParticipantStatus.accepted.rawValue],
                                  encoding: JSONEncoding())
    }
}

