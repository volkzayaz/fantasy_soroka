//
//  ActivateRoomResource.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 01.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import Moya

struct ActivateRoomResource: AuthorizedAPIResource {
    private let roomId: String

    init(roomId: String) {
        self.roomId = roomId
    }

    typealias responseType = Room

    var method: Moya.Method {
        return .post
    }

    var path: String {
        return "users/me/rooms/\(roomId)/activate"
    }

    var task: Task {
        return .requestPlain
    }
}
