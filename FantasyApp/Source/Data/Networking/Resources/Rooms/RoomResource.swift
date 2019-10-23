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
    private let id: String

    init(id: String) {
        self.id = id
    }

    typealias responseType = Room

    var method: Moya.Method {
        return .get
    }

    var path: String {
        return "users/me/rooms/\(id)"
    }

    var task: Task {
        return .requestPlain
    }
}

struct DeletedRoomResource: AuthorizedAPIResource {
    private let id: String

    init(id: String) {
        self.id = id
    }

    typealias responseType = Room

    var method: Moya.Method {
        return .get
    }

    var path: String {
        return "/users/me/rooms/deleted"
    }
    
    struct DeletedRoom {
        let roomId: String
    }

    var task: Task {
        return .requestPlain
    }
}


