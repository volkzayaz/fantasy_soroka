//
//  InviteParticipantResource.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 09.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import Moya

struct InviteParticipantResource: AuthorizedAPIResource {
    private let participant: Chat.RoomParticipant
    private let roomId: String

    init(roomId: String, participant: Chat.RoomParticipant) {
        self.roomId = roomId
        self.participant = participant
    }

    typealias responseType = Chat.Room

    var method: Moya.Method {
        return .post
    }

    var path: String {
        return "users/me/rooms/\(roomId)/participants"
    }

    var task: Task {
        return .requestJSONEncodable(participant)
    }
}
