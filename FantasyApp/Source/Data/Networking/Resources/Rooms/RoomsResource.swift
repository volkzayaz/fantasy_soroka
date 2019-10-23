//
//  RoomsResource.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 01.10.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import Moya

struct RoomsResource: AuthorizedAPIResource {
    typealias responseType = [Room]

    var method: Moya.Method {
        return .get
    }

    var path: String {
        return "users/me/rooms"
    }

    var task: Task {
        return .requestPlain
    }
}
