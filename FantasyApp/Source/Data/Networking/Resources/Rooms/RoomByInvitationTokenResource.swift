//
//  RoomByInvitationTokenResource.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 14.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import Moya

struct RoomByInvitationTokenResource: AuthorizedAPIResource {
    private let token: String

    init(token: String) {
        self.token = token
    }

    typealias responseType = Room

    var method: Moya.Method {
        return .get
    }

    var path: String {
        return "users/me/rooms/invite/\(token)"
    }

    var task: Task {
        return .requestPlain
    }
}

