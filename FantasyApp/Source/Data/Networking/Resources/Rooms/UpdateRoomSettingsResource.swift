//
//  UpdateRoomSettingsResource.swift
//  FantasyApp
//
//  Created by Admin on 01.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import Moya

struct UpdateRoomSettingsResource: AuthorizedAPIResource {
    private let roomId: String
    private let settings: Chat.RoomSettings

    init(roomId: String, settings: Chat.RoomSettings) {
        self.roomId = roomId
        self.settings = settings
    }

    typealias responseType = Chat.Room

    var method: Moya.Method {
        return .put
    }

    var path: String {
        return "users/me/rooms/\(roomId)/settings"
    }

    var task: Task {
        return .requestJSONEncodable(settings)
    }
}
