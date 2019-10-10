//
//  CreateDraftRoomResource.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 01.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import Moya

struct CreateDraftRoomResource: AuthorizedAPIResource {
    private let settings: Chat.RoomSettings

    init(settings: Chat.RoomSettings) {
        self.settings = settings
    }

    typealias responseType = Chat.Room

    var method: Moya.Method {
        return .post
    }

    var path: String {
        return "users/me/rooms"
    }

    var task: Task {
        return .requestJSONEncodable(settings)
    }
}
