//
//  RoomResource.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 01.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import Moya

struct RoomResource: AuthorizedAPIResource {
    private let roomId: String

    init(roomId: String) {
        self.roomId = roomId
    }

    typealias responseType = Chat.Room

    var method: Moya.Method {
        return .get
    }

    var path: String {
        return "users/me/rooms/\(roomId)"
    }

    var task: Task {
        return .requestPlain
    }
}
