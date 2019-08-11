//
//  Avatar.swift
//  newpl
//
//  Created by Admin on 08.07.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation

struct Avatar: Decodable {
    let id: String
    let email: String
    let avatar: URL
    let avatarThumbnail: URL

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case email
        case avatar
        case avatarThumbnail
    }
}
