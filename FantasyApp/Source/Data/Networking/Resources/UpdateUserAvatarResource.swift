//
//  UpdateUserAvatarResource.swift
//  newpl
//
//  Created by Borys Vynohradov on 08.07.2019.
//  Copyright © 2019 Andriy Yaroshenko. All rights reserved.
//

import Foundation

struct UpdateUserAvatarResource: AuthorizedAPIResource {
    var endpoint: APIEnpdoint {
        return .updateAvatar
    }

    typealias responseType = Avatar

    private let imageData: String

    init(imageData: String) {
        self.imageData = "data:image/png;base64, " + imageData
    }

    enum CodingKeys: String, CodingKey {
        case imageData = "image"
    }
}
