//
//  UpdateRoomSettingsResource.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 01.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import Moya

struct UpdateRoomSettingsResource: AuthorizedAPIResource {
    private let roomId: String
    private let settings: Room.Settings

    init(roomId: String, settings: Room.Settings) {
        self.roomId = roomId
        self.settings = settings
    }

    typealias responseType = Room

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

struct UpdateRoomSharedCollectionsResource: AuthorizedAPIResource {
    
    let room: Room
    
    typealias responseType = Room

    var method: Moya.Method {
        return .put
    }

    var path: String {
        return "users/me/rooms/\(room.id)/settings/shared-collections"
    }

    var task: Task {
        return .requestJSONEncodable(room.settings.sharedCollections)
    }
}

struct RoomsSharedCollectionsResource: AuthorizedAPIResource {
    
    let room: Room
    
    struct Response: Codable {
        let settings: Settings
        
        struct Settings: Codable {
            let sharedCollectionsData: [Fantasy.Collection]
        }
        
    }
    
    typealias responseType = Response

    var method: Moya.Method {
        return .get
    }

    var path: String {
        return "users/me/rooms/\(room.id)"
    }

    var task: Task {
        return .requestPlain
    }
}
