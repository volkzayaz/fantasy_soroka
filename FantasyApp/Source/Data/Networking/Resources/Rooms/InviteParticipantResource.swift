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
    private let userId: String?
    private let roomId: String

    init(roomId: String, userId: String?) {
        self.roomId = roomId
        self.userId = userId
    }

    typealias responseType = Room

    var method: Moya.Method {
        return .post
    }

    var path: String {
        return "users/me/rooms/\(roomId)/participants"
    }

    var task: Task {
        if let userId = userId {
            return .requestParameters(parameters: ["userId": userId], encoding: JSONEncoding.default)
        } else {
            return .requestParameters(parameters: ["isNewUser": true], encoding: JSONEncoding.default)
        }
    }
}
